# -----------------------------------------------------------------------------
# Basic Example Outputs
# -----------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail."
  value       = module.cloudtrail_basic.cloudtrail_arn
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail."
  value       = module.cloudtrail_basic.cloudtrail_name
}

output "s3_bucket_id" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = module.cloudtrail_basic.s3_bucket_id
}

output "cloudwatch_log_group_name" {
  description = "The CloudWatch log group for CloudTrail."
  value       = module.cloudtrail_basic.cloudwatch_log_group_name
}
