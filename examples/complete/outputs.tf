# -----------------------------------------------------------------------------
# Complete Example Outputs
# -----------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "The ARN of the complete CloudTrail."
  value       = module.cloudtrail_complete.cloudtrail_arn
}

output "cloudtrail_name" {
  description = "The name of the complete CloudTrail."
  value       = module.cloudtrail_complete.cloudtrail_name
}

output "s3_bucket_id" {
  description = "The S3 bucket used for complete CloudTrail logs."
  value       = module.cloudtrail_complete.s3_bucket_id
}

output "kms_key_arn" {
  description = "The KMS key ARN used for complete CloudTrail encryption."
  value       = module.cloudtrail_complete.kms_key_arn
}

output "cloudwatch_log_group_name" {
  description = "The CloudWatch log group for complete CloudTrail."
  value       = module.cloudtrail_complete.cloudwatch_log_group_name
}

output "sns_topic_arn" {
  description = "The SNS topic for complete CloudTrail notifications."
  value       = module.cloudtrail_complete.sns_topic_arn
}
