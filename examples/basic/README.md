# Terraform AWS CloudTrail Basic Example

This example demonstrates how to deploy a cost-optimized, minimal AWS CloudTrail configuration for account-wide audit logging.

## Features

- **Multi-region Trail**: Captures all management events across all regions
- **S3 Logging**: Automatically provisions an S3 bucket for storing logs
- **Cost Optimization**: Uses aggressive lifecycle policies to reduce storage costs
- **Security Best Practices**: Enforces public access blocking and S3 encryption (AES256)
- **Lean Setup**: No CloudWatch Logs, KMS, or SNS — avoids additional charges
- **Testing Friendly**: Includes force_destroy for easy cleanup during testing
- **Tagging Support**: All resources support custom tags

## Cost Optimization

This example is designed to **minimize costs** by:

- **No CloudWatch Logs**: Avoids log ingestion and storage fees
- **No KMS Encryption**: Uses S3 default encryption (AES256) instead of KMS
- **No SNS Notifications**: Eliminates notification costs
- **Fast Expiration**: Automatically deletes logs after 7 days to stay within free tier limits
- **No Storage Transitions**: Logs expire before expensive transitions occur

## Usage

### **Initialize and Apply**

```bash
terraform init
terraform plan
terraform apply
```

### **Destroy Resources**

```bash
terraform destroy
```

> **Note:** This example uses `force_destroy = true` on the S3 bucket for easy testing cleanup.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for CloudTrail name (with random suffix) | `string` | `"basic-example-{random}"` |
| `create_s3_bucket` | Create S3 bucket for logs | `bool` | `true` |
| `s3_bucket_force_destroy` | Force destroy S3 bucket for testing | `bool` | `true` |
| `s3_bucket_lifecycle_configuration` | S3 lifecycle policies | `list(object)` | 7-day expiration |
| `create_cloudwatch_log_group` | Create CloudWatch log group | `bool` | `false` |
| `create_kms_key` | Create KMS key for encryption | `bool` | `false` |
| `create_sns_topic` | Create SNS topic for notifications | `bool` | `false` |
| `tags` | Resource tags | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `cloudtrail_arn` | ARN of the CloudTrail |
| `cloudtrail_name` | Name of the CloudTrail |
| `s3_bucket_id` | S3 bucket used for logs |
| `cloudwatch_log_group_name` | CloudWatch log group name (null in basic) |

## Resources Created

- **CloudTrail** with multi-region configuration
- **S3 Bucket** for audit log storage with 7-day lifecycle expiration
- **S3 Bucket Policies** for secure CloudTrail access

This example provides a **cost-optimized CloudTrail deployment** with essential logging capabilities and automatic cleanup for testing environments.
