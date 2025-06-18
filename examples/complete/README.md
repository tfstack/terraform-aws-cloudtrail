# Terraform AWS CloudTrail Complete Example

This example demonstrates how to deploy a comprehensive AWS CloudTrail with all features enabled, including encryption, lifecycle management, and advanced event monitoring.

## Features

- **Complete CloudTrail Setup**: Full-featured multi-region trail with all capabilities
- **KMS Encryption**: Automated KMS key creation for CloudTrail log encryption
- **S3 Integration**: Advanced S3 bucket with lifecycle policies and versioning
- **CloudWatch Logs**: Real-time log monitoring with configurable retention
- **SNS Notifications**: Event notifications for CloudTrail activities
- **Event Selectors**: Comprehensive data event logging for S3 and Lambda
- **Advanced Event Selectors**: Fine-grained control over event logging
- **CloudTrail Insights**: API call rate analysis and anomaly detection
- **Lifecycle Management**: Cost optimization through automated storage transitions
- **Security Best Practices**: Complete security hardening and compliance

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

> **Warning:** Running this example creates AWS resources that incur costs.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for CloudTrail resources | `string` | `"example-complete"` |
| `create_s3_bucket` | Create S3 bucket for logs | `bool` | `true` |
| `create_kms_key` | Create KMS key for encryption | `bool` | `true` |
| `create_cloudwatch_log_group` | Create CloudWatch log group | `bool` | `true` |
| `create_sns_topic` | Create SNS topic for notifications | `bool` | `true` |
| `s3_bucket_lifecycle_configuration` | S3 lifecycle policies | `list(object)` | Configured |
| `cloudwatch_log_group_retention_in_days` | CloudWatch log retention | `number` | `30` |
| `enable_data_events_for_all_s3_buckets` | Enable S3 data events | `bool` | `true` |
| `enable_data_events_for_all_lambda_functions` | Enable Lambda data events | `bool` | `true` |
| `advanced_event_selector` | Advanced event selectors | `list(object)` | Configured |
| `insight_selector` | CloudTrail Insights configuration | `list(object)` | API rate insights |
| `tags` | Resource tags | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `cloudtrail_arn` | ARN of the complete CloudTrail |
| `cloudtrail_name` | Name of the complete CloudTrail |
| `s3_bucket_id` | S3 bucket used for logs |
| `kms_key_arn` | KMS key ARN for encryption |
| `cloudwatch_log_group_name` | CloudWatch log group name |
| `sns_topic_arn` | SNS topic ARN for notifications |

## Resources Created

- **CloudTrail** with comprehensive event logging and insights
- **KMS Key** with CloudTrail-specific encryption policies
- **S3 Bucket** with lifecycle management, versioning, and security
- **CloudWatch Log Group** with configurable retention policies
- **SNS Topic** for real-time event notifications
- **IAM Roles** for CloudWatch Logs and service integrations
- **S3 Bucket Policies** for secure CloudTrail access
- **Advanced Event Selectors** for fine-grained event control

This example provides a **production-ready CloudTrail deployment** with enterprise-grade features and cost optimization.
