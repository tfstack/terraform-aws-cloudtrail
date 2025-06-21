# terraform-aws-cloudtrail

Terraform module for AWS CloudTrail with secure logging and retention

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sns_topic.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_event_selector"></a> [advanced\_event\_selector](#input\_advanced\_event\_selector) | Advanced event selector for fine-grained control over events. Note: When using advanced event selectors, basic event selectors (including enable\_data\_events\_for\_all\_*) are automatically disabled to avoid conflicts. | <pre>list(object({<br/>    name = string<br/>    field_selector = list(object({<br/>      field           = string<br/>      equals          = optional(list(string), [])<br/>      not_equals      = optional(list(string), [])<br/>      starts_with     = optional(list(string), [])<br/>      not_starts_with = optional(list(string), [])<br/>      ends_with       = optional(list(string), [])<br/>      not_ends_with   = optional(list(string), [])<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_watch_logs_group_arn"></a> [cloud\_watch\_logs\_group\_arn](#input\_cloud\_watch\_logs\_group\_arn) | CloudWatch Logs group ARN for CloudTrail logs. Must end with ':*' to allow CloudTrail to create log streams. | `string` | `null` | no |
| <a name="input_cloud_watch_logs_role_arn"></a> [cloud\_watch\_logs\_role\_arn](#input\_cloud\_watch\_logs\_role\_arn) | CloudWatch Logs role ARN for CloudTrail. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | KMS key ID for encrypting CloudWatch logs. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain CloudWatch logs. | `number` | `14` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Whether to create a CloudWatch log group for CloudTrail. | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a KMS key for CloudTrail encryption. | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create an S3 bucket for CloudTrail logs. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create an SNS topic for CloudTrail notifications. | `bool` | `false` | no |
| <a name="input_enable_data_events_for_all_lambda_functions"></a> [enable\_data\_events\_for\_all\_lambda\_functions](#input\_enable\_data\_events\_for\_all\_lambda\_functions) | Enable data events for all Lambda functions. Note: This is ignored when advanced\_event\_selector is used. | `bool` | `false` | no |
| <a name="input_enable_data_events_for_all_s3_buckets"></a> [enable\_data\_events\_for\_all\_s3\_buckets](#input\_enable\_data\_events\_for\_all\_s3\_buckets) | Enable data events for all S3 buckets. Note: This is ignored when advanced\_event\_selector is used. | `bool` | `false` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Enable log file integrity validation. | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable logging for the trail. | `bool` | `true` | no |
| <a name="input_event_selector"></a> [event\_selector](#input\_event\_selector) | Event selector configuration for the CloudTrail. | <pre>list(object({<br/>    read_write_type                  = optional(string, "All")<br/>    include_management_events        = optional(bool, true)<br/>    exclude_management_event_sources = optional(list(string), [])<br/>    data_resource = optional(list(object({<br/>      type   = string<br/>      values = list(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Include events from global services like IAM. | `bool` | `true` | no |
| <a name="input_insight_selector"></a> [insight\_selector](#input\_insight\_selector) | CloudTrail Insights configuration. | <pre>list(object({<br/>    insight_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Make this trail multi-region. | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Make this trail an organization trail. | `bool` | `false` | no |
| <a name="input_kms_key_deletion_window_in_days"></a> [kms\_key\_deletion\_window\_in\_days](#input\_kms\_key\_deletion\_window\_in\_days) | Number of days to wait before deleting the KMS key. | `number` | `7` | no |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | Description for the KMS key. | `string` | `"KMS key for CloudTrail encryption"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for encrypting CloudTrail logs. | `string` | `null` | no |
| <a name="input_kms_key_policy"></a> [kms\_key\_policy](#input\_kms\_key\_policy) | Custom KMS key policy. If not provided, a default policy will be created. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the CloudTrail. This name will be used as a base for all related resources. | `string` | n/a | yes |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | Force destroy S3 bucket even if it contains objects. Useful for testing environments. | `bool` | `false` | no |
| <a name="input_s3_bucket_lifecycle_configuration"></a> [s3\_bucket\_lifecycle\_configuration](#input\_s3\_bucket\_lifecycle\_configuration) | S3 bucket lifecycle configuration for CloudTrail logs. | <pre>list(object({<br/>    id     = string<br/>    status = optional(string, "Enabled")<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      tags   = optional(map(string), {})<br/>    }), {})<br/>    transition = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })), [])<br/>    expiration = optional(object({<br/>      days = number<br/>    }), null)<br/>    noncurrent_version_transition = optional(list(object({<br/>      noncurrent_days = number<br/>      storage_class   = string<br/>    })), [])<br/>    noncurrent_version_expiration = optional(object({<br/>      noncurrent_days = number<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_s3_bucket_notification"></a> [s3\_bucket\_notification](#input\_s3\_bucket\_notification) | S3 bucket notification configuration. | <pre>object({<br/>    topic = optional(list(object({<br/>      topic_arn     = string<br/>      events        = list(string)<br/>      filter_prefix = optional(string)<br/>      filter_suffix = optional(string)<br/>    })), [])<br/>    queue = optional(list(object({<br/>      queue_arn     = string<br/>      events        = list(string)<br/>      filter_prefix = optional(string)<br/>      filter_suffix = optional(string)<br/>    })), [])<br/>    lambda_function = optional(list(object({<br/>      lambda_function_arn = string<br/>      events              = list(string)<br/>      filter_prefix       = optional(string)<br/>      filter_suffix       = optional(string)<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "lambda_function": [],<br/>  "queue": [],<br/>  "topic": []<br/>}</pre> | no |
| <a name="input_s3_bucket_policy"></a> [s3\_bucket\_policy](#input\_s3\_bucket\_policy) | Custom S3 bucket policy. If not provided, a default policy will be created. | `string` | `null` | no |
| <a name="input_s3_bucket_public_access_block"></a> [s3\_bucket\_public\_access\_block](#input\_s3\_bucket\_public\_access\_block) | S3 bucket public access block configuration. | <pre>object({<br/>    block_public_acls       = optional(bool, true)<br/>    block_public_policy     = optional(bool, true)<br/>    ignore_public_acls      = optional(bool, true)<br/>    restrict_public_buckets = optional(bool, true)<br/>  })</pre> | <pre>{<br/>  "block_public_acls": true,<br/>  "block_public_policy": true,<br/>  "ignore_public_acls": true,<br/>  "restrict_public_buckets": true<br/>}</pre> | no |
| <a name="input_s3_bucket_server_side_encryption_configuration"></a> [s3\_bucket\_server\_side\_encryption\_configuration](#input\_s3\_bucket\_server\_side\_encryption\_configuration) | S3 bucket server-side encryption configuration. | <pre>object({<br/>    rule = object({<br/>      apply_server_side_encryption_by_default = object({<br/>        sse_algorithm     = optional(string, "AES256")<br/>        kms_master_key_id = optional(string)<br/>      })<br/>      bucket_key_enabled = optional(bool, true)<br/>    })<br/>  })</pre> | <pre>{<br/>  "rule": {<br/>    "apply_server_side_encryption_by_default": {<br/>      "sse_algorithm": "AES256"<br/>    },<br/>    "bucket_key_enabled": true<br/>  }<br/>}</pre> | no |
| <a name="input_s3_bucket_versioning"></a> [s3\_bucket\_versioning](#input\_s3\_bucket\_versioning) | S3 bucket versioning configuration. | <pre>object({<br/>    enabled    = optional(bool, true)<br/>    mfa_delete = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "mfa_delete": false<br/>}</pre> | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | Prefix for CloudTrail log files in the S3 bucket. | `string` | `"cloudtrail-logs"` | no |
| <a name="input_sns_topic_policy"></a> [sns\_topic\_policy](#input\_sns\_topic\_policy) | Custom SNS topic policy. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The Amazon Resource Name of the trail. |
| <a name="output_cloudtrail_home_region"></a> [cloudtrail\_home\_region](#output\_cloudtrail\_home\_region) | The region in which the trail was created. |
| <a name="output_cloudtrail_id"></a> [cloudtrail\_id](#output\_cloudtrail\_id) | The name of the trail. |
| <a name="output_cloudtrail_name"></a> [cloudtrail\_name](#output\_cloudtrail\_name) | The name of the trail. |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The Amazon Resource Name (ARN) specifying the log group. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group. |
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | The Amazon Resource Name (ARN) of the CloudWatch Logs role. |
| <a name="output_cloudwatch_logs_role_name"></a> [cloudwatch\_logs\_role\_name](#output\_cloudwatch\_logs\_role\_name) | The name of the CloudWatch Logs role. |
| <a name="output_kms_alias_arn"></a> [kms\_alias\_arn](#output\_kms\_alias\_arn) | The Amazon Resource Name (ARN) of the KMS alias. |
| <a name="output_kms_alias_name"></a> [kms\_alias\_name](#output\_kms\_alias\_name) | The display name of the KMS alias. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The Amazon Resource Name (ARN) of the KMS key. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The globally unique identifier for the KMS key. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket used for CloudTrail logs. |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | The bucket domain name of the S3 bucket used for CloudTrail logs. |
| <a name="output_s3_bucket_hosted_zone_id"></a> [s3\_bucket\_hosted\_zone\_id](#output\_s3\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for the S3 bucket's region. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the S3 bucket used for CloudTrail logs. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this S3 bucket resides in. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic. |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | The name of the SNS topic. |
<!-- END_TF_DOCS -->
