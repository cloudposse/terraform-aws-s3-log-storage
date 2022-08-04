# ------------------------------------------------------------------------------
# S3 Bucket Meta
# ------------------------------------------------------------------------------
module "s3_bucket_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  name    = "aws-config-logs"
}

locals {
  aws_config_logs_bucket_arn    = format("arn:%s:s3:::%s", data.aws_partition.current.id, module.s3_bucket_meta.id)
  aws_config_logs_object_prefix = format("%s/AWSLogs/*", local.aws_config_logs_bucket_arn)
}


# ------------------------------------------------------------------------------
# S3 Bucket Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_bucket" {
  count       = module.this.enabled ? 1 : 0
  source_json = var.s3_bucket_policy_source_json

  statement {
    sid = "AWSConfigBucketPermissionsCheck"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    resources = [
      local.aws_config_logs_bucket_arn
    ]
  }

  statement {
    sid = "AWSConfigBucketExistenceCheck"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect  = "Allow"
    actions = ["s3:ListBucket"]

    resources = [
      local.aws_config_logs_bucket_arn
    ]
  }

  statement {
    sid = "AWSConfigBucketDelivery"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect  = "Allow"
    actions = ["s3:PutObject"]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    resources = [local.aws_config_logs_object_prefix]
  }
}


# ------------------------------------------------------------------------------
# S3 Bucket
# ------------------------------------------------------------------------------
module "s3_bucket" {
  source  = "../../"
  context = module.s3_bucket_meta.context

  access_log_bucket_name            = var.access_log_bucket_name
  access_log_bucket_prefix_override = var.access_log_bucket_prefix_override
  acl                               = "log-delivery-write"
  allow_encrypted_uploads_only      = false
  allow_ssl_requests_only           = true
  block_public_acls                 = true
  block_public_policy               = true
  bucket_key_enabled                = false
  bucket_name                       = ""
  bucket_notifications_enabled      = false
  bucket_notifications_prefix       = ""
  bucket_notifications_type         = "SQS"
  force_destroy                     = var.force_destroy
  ignore_public_acls                = true
  kms_master_key_arn                = module.kms_key.key_arn
  lifecycle_configuration_rules     = var.lifecycle_configuration_rules
  restrict_public_buckets           = true
  s3_object_ownership               = "BucketOwnerEnforced"
  source_policy_documents           = [one(data.aws_iam_policy_document.s3_bucket[*].json)]
  sse_algorithm                     = module.kms_key.alias_arn == "" ? "AES256" : "aws:kms"
  versioning_enabled                = true
}
