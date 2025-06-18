provider "aws" {
  region = "ap-southeast-2"
}

# Test basic CloudTrail functionality (cost-optimized)
run "basic_test" {
  command = plan

  variables {
    name             = "test-cloudtrail-basic"
    create_s3_bucket = true

    # Force destroy for testing
    s3_bucket_force_destroy = true

    # Cost optimization with lifecycle transitions
    s3_bucket_lifecycle_configuration = [
      {
        id     = "test-cost-optimization"
        status = "Enabled"
        filter = {
          prefix = ""
        }
        expiration = {
          days = 7
        }
      }
    ]

    # Keep costs minimal
    create_cloudwatch_log_group = false
    create_kms_key              = false
    create_sns_topic            = false

    tags = {
      Test        = "basic_test"
      Environment = "test"
    }
  }
}

# Test complete CloudTrail configuration
run "complete_test" {
  command = plan

  variables {
    name                        = "test-complete-cloudtrail"
    create_s3_bucket            = true
    create_kms_key              = true
    create_cloudwatch_log_group = true
    create_sns_topic            = true

    # Force destroy for testing
    s3_bucket_force_destroy = true

    s3_bucket_lifecycle_configuration = [
      {
        id     = "test-lifecycle"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
        expiration = {
          days = 90
        }
      }
    ]

    tags = {
      Test        = "complete_test"
      Environment = "test"
    }
  }
}
