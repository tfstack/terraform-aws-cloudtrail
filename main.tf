# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  cloudtrail_name = var.name
  s3_bucket_name  = "${var.name}-cloudtrail-logs"

  # Default S3 bucket policy for CloudTrail
  default_s3_bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.s3_bucket_name}"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.s3_bucket_name}/${var.s3_key_prefix}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "AWS:SourceArn" = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
          }
        }
      }
    ]
  })

  # Default KMS key policy
  default_kms_key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
          }
        }
      }
    ]
  })

  # CloudWatch log group name
  cloudwatch_log_group_name = "/aws/cloudtrail/${local.cloudtrail_name}"

  # Common tags
  common_tags = merge(var.tags, {
    "terraform-aws-cloudtrail" = "true"
    "CloudTrail"               = local.cloudtrail_name
  })

  # Default event selector for all S3 buckets and Lambda functions
  default_event_selectors = concat(
    var.enable_data_events_for_all_s3_buckets ? [{
      read_write_type           = "All"
      include_management_events = true
      data_resource = [{
        type   = "AWS::S3::Object"
        values = ["arn:${data.aws_partition.current.partition}:s3:::*/*"]
      }]
    }] : [],
    var.enable_data_events_for_all_lambda_functions ? [{
      read_write_type           = "All"
      include_management_events = true
      data_resource = [{
        type   = "AWS::Lambda::Function"
        values = ["arn:${data.aws_partition.current.partition}:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"]
      }]
    }] : [],
    var.event_selector
  )
}

# -----------------------------------------------------------------------------
# KMS Key for CloudTrail (Optional)
# -----------------------------------------------------------------------------

resource "aws_kms_key" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  policy                  = var.kms_key_policy != null ? var.kms_key_policy : local.default_kms_key_policy

  tags = merge(local.common_tags, {
    Name = "${local.cloudtrail_name}-kms-key"
  })
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${local.cloudtrail_name}-key"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

# -----------------------------------------------------------------------------
# S3 Bucket for CloudTrail Logs (Optional)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket        = local.s3_bucket_name
  force_destroy = var.s3_bucket_force_destroy

  tags = merge(local.common_tags, {
    Name = local.s3_bucket_name
  })
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = var.s3_bucket_policy != null ? var.s3_bucket_policy : local.default_s3_bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.cloudtrail]
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = var.s3_bucket_public_access_block.block_public_acls
  block_public_policy     = var.s3_bucket_public_access_block.block_public_policy
  ignore_public_acls      = var.s3_bucket_public_access_block.ignore_public_acls
  restrict_public_buckets = var.s3_bucket_public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status     = var.s3_bucket_versioning.enabled ? "Enabled" : "Suspended"
    mfa_delete = var.s3_bucket_versioning.mfa_delete ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_bucket_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
      kms_master_key_id = var.s3_bucket_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id
    }
    bucket_key_enabled = var.s3_bucket_server_side_encryption_configuration.rule.bucket_key_enabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = var.create_s3_bucket && length(var.s3_bucket_lifecycle_configuration) > 0 ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  dynamic "rule" {
    for_each = var.s3_bucket_lifecycle_configuration
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition != null ? rule.value.transition : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition != null ? rule.value.noncurrent_version_transition : []
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.cloudtrail]
}

resource "aws_s3_bucket_notification" "cloudtrail" {
  count = var.create_s3_bucket && (
    length(var.s3_bucket_notification.topic) > 0 ||
    length(var.s3_bucket_notification.queue) > 0 ||
    length(var.s3_bucket_notification.lambda_function) > 0
  ) ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  dynamic "topic" {
    for_each = var.s3_bucket_notification.topic
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.s3_bucket_notification.queue
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  dynamic "lambda_function" {
    for_each = var.s3_bucket_notification.lambda_function
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group (Optional)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(local.common_tags, {
    Name = local.cloudwatch_log_group_name
  })
}

# IAM role for CloudWatch Logs
resource "aws_iam_role" "cloudwatch_logs" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name = "CloudTrail-CloudWatchLogsRole-${local.cloudtrail_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name = "CloudTrail-CloudWatchLogsPolicy"
  role = aws_iam_role.cloudwatch_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# SNS Topic (Optional)
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "cloudtrail" {
  count = var.create_sns_topic ? 1 : 0

  name = "${local.cloudtrail_name}-cloudtrail"

  tags = merge(local.common_tags, {
    Name = "${local.cloudtrail_name}-cloudtrail"
  })
}

resource "aws_sns_topic_policy" "cloudtrail" {
  count = var.create_sns_topic ? 1 : 0

  arn = aws_sns_topic.cloudtrail[0].arn

  policy = var.sns_topic_policy != null ? var.sns_topic_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailSNSPolicy"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cloudtrail[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# CloudTrail
# -----------------------------------------------------------------------------

resource "aws_cloudtrail" "this" {
  name           = local.cloudtrail_name
  s3_bucket_name = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].id : local.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix

  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail

  # KMS encryption
  kms_key_id = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id

  # CloudWatch Logs
  cloud_watch_logs_group_arn = var.create_cloudwatch_log_group ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : var.cloud_watch_logs_group_arn
  cloud_watch_logs_role_arn  = var.create_cloudwatch_log_group ? aws_iam_role.cloudwatch_logs[0].arn : var.cloud_watch_logs_role_arn

  # SNS topic
  sns_topic_name = var.create_sns_topic ? aws_sns_topic.cloudtrail[0].name : null

  # Event selectors (only use if advanced_event_selector is not provided)
  dynamic "event_selector" {
    for_each = length(var.advanced_event_selector) == 0 ? local.default_event_selectors : []
    content {
      read_write_type                  = event_selector.value.read_write_type
      include_management_events        = event_selector.value.include_management_events
      exclude_management_event_sources = try(event_selector.value.exclude_management_event_sources, [])

      dynamic "data_resource" {
        for_each = try(event_selector.value.data_resource, [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  # Advanced event selectors
  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selector
    content {
      name = advanced_event_selector.value.name

      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selector
        content {
          field           = field_selector.value.field
          equals          = length(try(field_selector.value.equals, [])) > 0 ? field_selector.value.equals : null
          not_equals      = length(try(field_selector.value.not_equals, [])) > 0 ? field_selector.value.not_equals : null
          starts_with     = length(try(field_selector.value.starts_with, [])) > 0 ? field_selector.value.starts_with : null
          not_starts_with = length(try(field_selector.value.not_starts_with, [])) > 0 ? field_selector.value.not_starts_with : null
          ends_with       = length(try(field_selector.value.ends_with, [])) > 0 ? field_selector.value.ends_with : null
          not_ends_with   = length(try(field_selector.value.not_ends_with, [])) > 0 ? field_selector.value.not_ends_with : null
        }
      }
    }
  }

  # Insights
  dynamic "insight_selector" {
    for_each = var.insight_selector
    content {
      insight_type = insight_selector.value.insight_type
    }
  }

  tags = merge(local.common_tags, {
    Name = local.cloudtrail_name
  })

  depends_on = [
    aws_s3_bucket_policy.cloudtrail,
    aws_sns_topic_policy.cloudtrail,
    aws_cloudwatch_log_group.cloudtrail,
    aws_iam_role_policy.cloudwatch_logs
  ]
}
