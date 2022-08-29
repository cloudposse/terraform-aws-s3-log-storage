# ------------------------------------------------------------------------------
# S3 Log Storage Context
# ------------------------------------------------------------------------------
module "s3_log_storage_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.2"
  context    = module.context.self
  attributes = ["lb-access-logs"]
}


# ------------------------------------------------------------------------------
# S3 Log Storage IAM Policy
# ------------------------------------------------------------------------------
locals {
  s3_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${module.s3_log_storage_context.id}"
}

data "aws_elb_service_account" "s3_log_storage" {
  count = module.s3_log_storage_context.enabled ? 1 : 0
}

data "aws_iam_policy_document" "s3_log_storage" {
  count = module.s3_log_storage_context.enabled ? 1 : 0

  statement {
    sid = ""
    principals {
      type        = "AWS"
      identifiers = [join("", data.aws_elb_service_account.s3_log_storage.*.arn)]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${local.s3_bucket_arn}/*"]
  }
  statement {
    sid = ""
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${local.s3_bucket_arn}/*"]
    condition {
      test     = "StringEquals"
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
        ["${local.arn_format}:logs:*:${data.aws_caller_identity.current.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }
  }
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = ["${local.s3_bucket_arn}"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = concat([data.aws_caller_identity.current.account_id], var.source_accounts)
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = concat(
        ["${local.arn_format}:logs:*:${data.aws_caller_identity.current.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }
  }
}


# ------------------------------------------------------------------------------
# S3 Log Storage
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
