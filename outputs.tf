# -----------------------------------------------------------------------------
# CloudTrail Outputs
# -----------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail."
  value       = aws_cloudtrail.this.arn
}

output "cloudtrail_id" {
  description = "The name of the trail."
  value       = aws_cloudtrail.this.id
}

output "cloudtrail_name" {
  description = "The name of the trail."
  value       = aws_cloudtrail.this.name
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created."
  value       = aws_cloudtrail.this.home_region
}

# -----------------------------------------------------------------------------
# S3 Bucket Outputs
# -----------------------------------------------------------------------------

output "s3_bucket_id" {
  description = "The name of the S3 bucket used for CloudTrail logs."
  value       = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].id : local.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CloudTrail logs."
  value       = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name of the S3 bucket used for CloudTrail logs."
  value       = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].bucket_domain_name : null
}

output "s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the S3 bucket's region."
  value       = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].hosted_zone_id : null
}

output "s3_bucket_region" {
  description = "The AWS region this S3 bucket resides in."
  value       = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].region : null
}

# -----------------------------------------------------------------------------
# KMS Key Outputs
# -----------------------------------------------------------------------------

output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key."
  value       = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id
}

output "kms_key_id" {
  description = "The globally unique identifier for the KMS key."
  value       = var.create_kms_key ? aws_kms_key.cloudtrail[0].key_id : null
}

output "kms_alias_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS alias."
  value       = var.create_kms_key ? aws_kms_alias.cloudtrail[0].arn : null
}

output "kms_alias_name" {
  description = "The display name of the KMS alias."
  value       = var.create_kms_key ? aws_kms_alias.cloudtrail[0].name : null
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group Outputs
# -----------------------------------------------------------------------------

output "cloudwatch_log_group_arn" {
  description = "The Amazon Resource Name (ARN) specifying the log group."
  value       = var.create_cloudwatch_log_group ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : var.cloud_watch_logs_group_arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}

output "cloudwatch_logs_role_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch Logs role."
  value       = var.create_cloudwatch_log_group ? aws_iam_role.cloudwatch_logs[0].arn : var.cloud_watch_logs_role_arn
}

output "cloudwatch_logs_role_name" {
  description = "The name of the CloudWatch Logs role."
  value       = var.create_cloudwatch_log_group ? aws_iam_role.cloudwatch_logs[0].name : null
}

# -----------------------------------------------------------------------------
# SNS Topic Outputs
# -----------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = var.create_sns_topic ? aws_sns_topic.cloudtrail[0].arn : null
}

output "sns_topic_name" {
  description = "The name of the SNS topic."
  value       = var.create_sns_topic ? aws_sns_topic.cloudtrail[0].name : null
}
