provider "aws" {
  region = "ap-southeast-2"
}

# Generate a random suffix for uniqueness in examples
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name_prefix = "example-complete-${random_string.suffix.result}"

  tags = {
    Environment = "development"
    Project     = "terraform-aws-cloudtrail-example"
    Owner       = "terraform"
    Example     = "complete"
  }
}

# -----------------------------------------------------------------------------
# Complete CloudTrail with All Features
# -----------------------------------------------------------------------------

module "cloudtrail_complete" {
  source = "../../"

  # CloudTrail configuration
  name = local.name_prefix

  # Enable all features
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = false

  # S3 bucket configuration
  create_s3_bucket        = true
  s3_key_prefix           = "cloudtrail-logs"
  s3_bucket_force_destroy = true # For testing - allows easy cleanup

  # S3 bucket versioning
  s3_bucket_versioning = {
    enabled    = true
    mfa_delete = false
  }

  # S3 bucket lifecycle configuration
  s3_bucket_lifecycle_configuration = [
    {
      id     = "cloudtrail-logs-lifecycle"
      status = "Enabled"
      filter = {
        prefix = "cloudtrail-logs/"
      }
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 2555 # 7 years
      }
    }
  ]

  # KMS encryption
  create_kms_key                  = true
  kms_key_description             = "KMS key for CloudTrail encryption - Complete Example"
  kms_key_deletion_window_in_days = 7

  # CloudWatch Logs integration
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  # SNS notifications
  create_sns_topic = true

  # Advanced event selectors for fine-grained control
  # Note: When using advanced_event_selector, basic event selectors are automatically disabled
  # These examples show different patterns:
  # 1. S3 data events for specific bucket paths
  # 2. Lambda function data events
  # 3. All management events (cannot be combined with eventName filters)
  advanced_event_selector = [
    {
      name = "Log all S3 data events for specific bucket prefix"
      field_selector = [
        {
          field  = "eventCategory"
          equals = ["Data"]
        },
        {
          field  = "resources.type"
          equals = ["AWS::S3::Object"]
        },
        {
          field       = "resources.ARN"
          starts_with = ["arn:aws:s3:::example-bucket/important/"]
        }
      ]
    },
    {
      name = "Log all Lambda function data events"
      field_selector = [
        {
          field  = "eventCategory"
          equals = ["Data"]
        },
        {
          field  = "resources.type"
          equals = ["AWS::Lambda::Function"]
        }
      ]
    },
    {
      name = "Log all management events"
      field_selector = [
        {
          field  = "eventCategory"
          equals = ["Management"]
        }
      ]
    }
  ]

  # CloudTrail Insights
  insight_selector = [
    {
      insight_type = "ApiCallRateInsight"
    }
  ]

  tags = local.tags
}
