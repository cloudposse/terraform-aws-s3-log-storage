# ------------------------------------------------------------------------------
# S3 Log Storage Context
# ------------------------------------------------------------------------------
module "s3_log_storage_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.2"
  context    = module.context.self
  attributes = ["aws-config-logs"]
}

locals {
  s3_log_storage_arn = format("arn:%s:s3:::%s", data.aws_partition.current.id, module.s3_log_storage_context.id)
  s3_object_prefix   = format("%s/AWSLogs/*", local.s3_log_storage_arn)
}


# ------------------------------------------------------------------------------
# S3 Log StoragePolicy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_log_storage" {
  count = module.context.enabled ? 1 : 0
  #  source_policy_documents = var.s3_bucket_policy_source_json == "" ? [] : [var.s3_bucket_policy_source_json]

  statement {
    sid = "AWSConfigBucketPermissionsCheck"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    resources = [
      local.s3_log_storage_arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = concat([data.aws_caller_identity.current.account_id], var.source_accounts)
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = concat(
        ["${local.arn_prefix}:logs:*:${data.aws_caller_identity.current.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }
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
      local.s3_log_storage_arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = concat([data.aws_caller_identity.current.account_id], var.source_accounts)
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = concat(
        ["${local.arn_prefix}:logs:*:${data.aws_caller_identity.current.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }
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
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = concat([data.aws_caller_identity.current.account_id], var.source_accounts)
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = concat(
        ["${local.arn_prefix}:logs:*:${data.aws_caller_identity.current.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }

    resources = [local.s3_object_prefix]
  }
}


# ------------------------------------------------------------------------------
# S3 Bucket
# ------------------------------------------------------------------------------
module "s3_log_storage" {
  source  = "../../"
  context = module.s3_log_storage_context.self

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
  s3_object_ownership               = "BucketOwnerPreferred"
  source_policy_documents           = concat([one(data.aws_iam_policy_document.s3_log_storage[*].json)],var.s3_source_policy_documents)
  sse_algorithm                     = module.kms_key.alias_arn == "" ? "AES256" : "aws:kms"
  versioning_enabled                = true
}
