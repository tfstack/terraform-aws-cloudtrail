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
  tags = {
    Environment = "development"
    Project     = "terraform-aws-cloudtrail-example"
    Owner       = "terraform"
    Example     = "basic"
  }
}

# -----------------------------------------------------------------------------
# Basic CloudTrail Setup
# -----------------------------------------------------------------------------

module "cloudtrail_basic" {
  source = "../../"

  name = "basic-example-${random_string.suffix.result}"

  # Enable CloudTrail and create the required S3 bucket
  create_s3_bucket = true

  # Force destroy for testing - allows easy cleanup
  s3_bucket_force_destroy = true

  # Minimal S3 lifecycle: expire logs quickly to stay under free tier (5GB/month)
  s3_bucket_lifecycle_configuration = [
    {
      id     = "free-tier-expire-fast"
      status = "Enabled"
      filter = {
        prefix = "" # Or use "AWSLogs/" depending on your CloudTrail config
      }
      expiration = {
        days = 7
      }
    }
  ]

  # Disable optional features that incur cost
  create_cloudwatch_log_group = false
  create_kms_key              = false
  create_sns_topic            = false

  tags = local.tags
}
