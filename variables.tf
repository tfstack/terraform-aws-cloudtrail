# -----------------------------------------------------------------------------
# CloudTrail Configuration Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the CloudTrail. This name will be used as a base for all related resources."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.name)) && length(var.name) >= 3 && length(var.name) <= 128
    error_message = "CloudTrail name must be 3-128 characters long and contain only letters, numbers, periods, hyphens, and underscores."
  }
}



variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket for CloudTrail logs."
  type        = bool
  default     = true
}



variable "s3_bucket_force_destroy" {
  description = "Force destroy S3 bucket even if it contains objects. Useful for testing environments."
  type        = bool
  default     = false
}

variable "s3_key_prefix" {
  description = "Prefix for CloudTrail log files in the S3 bucket."
  type        = string
  default     = "cloudtrail-logs"

  validation {
    condition     = can(regex("^[a-zA-Z0-9!_.*'()/-]*$", var.s3_key_prefix))
    error_message = "S3 key prefix must contain only valid S3 key characters."
  }
}

# -----------------------------------------------------------------------------
# CloudTrail Features
# -----------------------------------------------------------------------------

variable "enable_logging" {
  description = "Enable logging for the trail."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file integrity validation."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Include events from global services like IAM."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Make this trail multi-region."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Make this trail an organization trail."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Event Selectors
# -----------------------------------------------------------------------------

variable "event_selector" {
  description = "Event selector configuration for the CloudTrail."
  type = list(object({
    read_write_type                  = optional(string, "All")
    include_management_events        = optional(bool, true)
    exclude_management_event_sources = optional(list(string), [])
    data_resource = optional(list(object({
      type   = string
      values = list(string)
    })), [])
  }))
  default = []

  validation {
    condition     = length(var.event_selector) <= 5
    error_message = "A maximum of 5 event selectors can be configured per trail."
  }

  validation {
    condition = alltrue([
      for es in var.event_selector : contains(["All", "ReadOnly", "WriteOnly"], es.read_write_type)
    ])
    error_message = "Event selector read_write_type must be one of: All, ReadOnly, WriteOnly."
  }
}

variable "advanced_event_selector" {
  description = "Advanced event selector for fine-grained control over events. Note: When using advanced event selectors, basic event selectors (including enable_data_events_for_all_*) are automatically disabled to avoid conflicts."
  type = list(object({
    name = string
    field_selector = list(object({
      field           = string
      equals          = optional(list(string), [])
      not_equals      = optional(list(string), [])
      starts_with     = optional(list(string), [])
      not_starts_with = optional(list(string), [])
      ends_with       = optional(list(string), [])
      not_ends_with   = optional(list(string), [])
    }))
  }))
  default = []

  validation {
    condition     = length(var.advanced_event_selector) <= 10
    error_message = "A maximum of 10 advanced event selectors can be configured per trail."
  }

  validation {
    condition = alltrue([
      for aes in var.advanced_event_selector : length(aes.field_selector) <= 20
    ])
    error_message = "Each advanced event selector can have a maximum of 20 field selectors."
  }

  validation {
    condition = alltrue([
      for aes in var.advanced_event_selector : alltrue([
        for fs in aes.field_selector : contains([
          "eventCategory", "eventName", "readOnly", "username", "resources.type",
          "resources.ARN", "userIdentity.type", "userIdentity.principalId",
          "userIdentity.arn", "userIdentity.accountId", "userIdentity.invokedBy",
          "userIdentity.accessKeyId", "userIdentity.userName", "userIdentity.sessionName",
          "sourceIPAddress", "vpcEndpointId", "tlsDetails.tlsVersion", "tlsDetails.cipherSuite",
          "tlsDetails.clientProvidedHostHeader"
        ], fs.field)
      ])
    ])
    error_message = "Field selector field must be a valid CloudTrail field name."
  }

  validation {
    condition = alltrue([
      for aes in var.advanced_event_selector : (
        # Check if this selector has eventCategory = Management
        length([for fs in aes.field_selector : fs if fs.field == "eventCategory" && contains(try(fs.equals, []), "Management")]) > 0 ?
        # If so, ensure no eventName field is used
        length([for fs in aes.field_selector : fs if fs.field == "eventName"]) == 0 :
        # Otherwise, allow any configuration
        true
      )
    ])
    error_message = "When eventCategory is set to 'Management', the eventName field cannot be used in the same advanced event selector."
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Integration
# -----------------------------------------------------------------------------

variable "cloud_watch_logs_group_arn" {
  description = "CloudWatch Logs group ARN for CloudTrail logs. Must end with ':*' to allow CloudTrail to create log streams."
  type        = string
  default     = null

  validation {
    condition     = var.cloud_watch_logs_group_arn == null || can(regex(":.*:\\*$", var.cloud_watch_logs_group_arn))
    error_message = "CloudWatch Logs group ARN must end with ':*' for CloudTrail compatibility."
  }
}

variable "cloud_watch_logs_role_arn" {
  description = "CloudWatch Logs role ARN for CloudTrail."
  type        = string
  default     = null
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group for CloudTrail."
  type        = bool
  default     = false
}



variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 14

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.cloudwatch_log_group_retention_in_days)
    error_message = "CloudWatch log group retention must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, or 3653 days."
  }
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ID for encrypting CloudWatch logs."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# KMS Encryption
# -----------------------------------------------------------------------------

variable "kms_key_id" {
  description = "KMS key ID for encrypting CloudTrail logs."
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Whether to create a KMS key for CloudTrail encryption."
  type        = bool
  default     = false
}

variable "kms_key_deletion_window_in_days" {
  description = "Number of days to wait before deleting the KMS key."
  type        = number
  default     = 7

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_description" {
  description = "Description for the KMS key."
  type        = string
  default     = "KMS key for CloudTrail encryption"
}

variable "kms_key_policy" {
  description = "Custom KMS key policy. If not provided, a default policy will be created."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# SNS Notification
# -----------------------------------------------------------------------------



variable "create_sns_topic" {
  description = "Whether to create an SNS topic for CloudTrail notifications."
  type        = bool
  default     = false
}

variable "sns_topic_policy" {
  description = "Custom SNS topic policy."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# S3 Bucket Configuration
# -----------------------------------------------------------------------------

variable "s3_bucket_policy" {
  description = "Custom S3 bucket policy. If not provided, a default policy will be created."
  type        = string
  default     = null
}

variable "s3_bucket_public_access_block" {
  description = "S3 bucket public access block configuration."
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "s3_bucket_versioning" {
  description = "S3 bucket versioning configuration."
  type = object({
    enabled    = optional(bool, true)
    mfa_delete = optional(bool, false)
  })
  default = {
    enabled    = true
    mfa_delete = false
  }
}

variable "s3_bucket_lifecycle_configuration" {
  description = "S3 bucket lifecycle configuration for CloudTrail logs."
  type = list(object({
    id     = string
    status = optional(string, "Enabled")
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string), {})
    }), {})
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration = optional(object({
      days = number
    }), null)
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }), null)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.s3_bucket_lifecycle_configuration : contains(["Enabled", "Disabled"], rule.status)
    ])
    error_message = "Lifecycle rule status must be either 'Enabled' or 'Disabled'."
  }

  validation {
    condition = alltrue([
      for rule in var.s3_bucket_lifecycle_configuration : alltrue([
        for transition in rule.transition : contains([
          "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR"
        ], transition.storage_class)
      ])
    ])
    error_message = "Transition storage class must be one of: STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE, GLACIER_IR."
  }

  validation {
    condition = alltrue([
      for rule in var.s3_bucket_lifecycle_configuration : alltrue([
        for transition in rule.transition : transition.days >= 1
      ])
    ])
    error_message = "Transition days must be at least 1."
  }
}

variable "s3_bucket_server_side_encryption_configuration" {
  description = "S3 bucket server-side encryption configuration."
  type = object({
    rule = object({
      apply_server_side_encryption_by_default = object({
        sse_algorithm     = optional(string, "AES256")
        kms_master_key_id = optional(string)
      })
      bucket_key_enabled = optional(bool, true)
    })
  })
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  validation {
    condition     = contains(["AES256", "aws:kms"], var.s3_bucket_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm)
    error_message = "SSE algorithm must be either 'AES256' or 'aws:kms'."
  }

  validation {
    condition = (
      var.s3_bucket_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm == "aws:kms" ?
      var.s3_bucket_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id != null :
      true
    )
    error_message = "KMS master key ID is required when using aws:kms encryption."
  }
}

variable "s3_bucket_notification" {
  description = "S3 bucket notification configuration."
  type = object({
    topic = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    queue = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    lambda_function = optional(list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })), [])
  })
  default = {
    topic           = []
    queue           = []
    lambda_function = []
  }
}

# -----------------------------------------------------------------------------
# Insights
# -----------------------------------------------------------------------------

variable "insight_selector" {
  description = "CloudTrail Insights configuration."
  type = list(object({
    insight_type = string
  }))
  default = []

  validation {
    condition = alltrue([
      for is in var.insight_selector : contains(["ApiCallRateInsight", "ApiErrorRateInsight"], is.insight_type)
    ])
    error_message = "Insight type must be either 'ApiCallRateInsight' or 'ApiErrorRateInsight'."
  }
}

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "enable_data_events_for_all_s3_buckets" {
  description = "Enable data events for all S3 buckets. Note: This is ignored when advanced_event_selector is used."
  type        = bool
  default     = false
}

variable "enable_data_events_for_all_lambda_functions" {
  description = "Enable data events for all Lambda functions. Note: This is ignored when advanced_event_selector is used."
  type        = bool
  default     = false
}
