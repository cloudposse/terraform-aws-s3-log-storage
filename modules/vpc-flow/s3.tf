# ------------------------------------------------------------------------------
# S3 Log Storage Labels
# ------------------------------------------------------------------------------
module "s3_log_storage_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["vpc-flow-logs"]
}


# ------------------------------------------------------------------------------
# S3 Log Storage IAM Policies
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_log_storage" {
  count                   = module.s3_log_storage_meta.enabled ? 1 : 0
#  source_policy_documents = var.s3_bucket_policy_source_json == "" ? [] : [var.s3_bucket_policy_source_json]

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${local.arn_format}:s3:::${module.s3_log_storage_meta.id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      "${local.arn_format}:s3:::${module.s3_log_storage_meta.id}"
    ]
  }
}


# ------------------------------------------------------------------------------
# S3 Log Storage
# ------------------------------------------------------------------------------
module "s3_log_storage" {
  source  = "../../"
  context = module.s3_log_storage_meta.context

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
  kms_master_key_arn                = module.kms_key.alias_arn
  lifecycle_configuration_rules     = var.lifecycle_configuration_rules
  restrict_public_buckets           = true
  s3_object_ownership               = "BucketOwnerPreferred"
  source_policy_documents           = [one(data.aws_iam_policy_document.s3_log_storage[*].json)]
  sse_algorithm                     = module.kms_key.alias_arn == "" ? "AES256" : "aws:kms"
  versioning_enabled                = true
}
