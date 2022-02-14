resource "aws_s3_bucket" "default" {
  #bridgecrew:skip=BC_AWS_S3_13:Skipping `Enable S3 Bucket Logging` check until bridgecrew will support dynamic blocks (https://github.com/bridgecrewio/checkov/issues/776).
  #bridgecrew:skip=CKV_AWS_52:Skipping `Ensure S3 bucket has MFA delete enabled` due to issue in terraform (https://github.com/hashicorp/terraform-provider-aws/issues/629).
  count         = module.this.enabled ? 1 : 0
  bucket        = module.this.id
  force_destroy = var.force_destroy

  tags = module.this.tags
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = module.this.enabled ? 1 : 0
  bucket = aws_s3_bucket.default[0].id
  acl    = var.acl
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = module.this.enabled ? 1 : 0
  bucket = aws_s3_bucket.default[0].id
  policy = var.policy
}

resource "aws_s3_bucket_versioning" "log_bucket" {
  count  = module.this.enabled ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  versioning_configuration {
    status     = var.versioning_enabled ? "Enabled" : "Suspended"
    mfa_delete = var.versioning_mfa_delete_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  // MFA Enabled is not compatible with lifecycle management - https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-and-other-bucket-config.html
  count = module.this.enabled && ! var.versioning_mfa_delete_enabled ? 1 : 0

  bucket = aws_s3_bucket.default[0].bucket

  rule {
    id     = module.this.id
    status = var.lifecycle_rule_enabled ? "Enabled" : "Disabled"

    filter {
      and {
        prefix = var.lifecycle_prefix
        tags   = var.lifecycle_tags
      }
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.enable_glacier_transition ? [1] : []

      content {
        noncurrent_days = var.noncurrent_version_transition_days
        storage_class   = "GLACIER"
      }
    }

    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"
    }

    dynamic "transition" {
      for_each = var.enable_glacier_transition ? [1] : []

      content {
        days          = var.glacier_transition_days
        storage_class = "GLACIER"
      }
    }

    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count  = module.this.enabled && var.access_log_bucket_name != "" ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  target_bucket = var.access_log_bucket_name
  target_prefix = "${var.access_log_bucket_prefix}${module.this.id}/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  count = module.this.enabled ? 1 : 0
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  bucket = aws_s3_bucket.default[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_arn
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  count = module.this.enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyIncorrectEncryptionHeader"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "StringNotEquals"
        values   = [var.sse_algorithm]
        variable = "s3:x-amz-server-side-encryption"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyUnEncryptedObjectUploads"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "Null"
        values   = ["true"]
        variable = "s3:x-amz-server-side-encryption"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_ssl_requests_only ? [1] : []

    content {
      sid     = "ForceSSLOnlyAccess"
      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}",
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"
      ]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "Bool"
        values   = ["false"]
        variable = "aws:SecureTransport"
      }
    }
  }
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "aggregated_policy" {
  count                     = module.this.enabled ? 1 : 0
  source_policy_documents   = [var.policy]
  override_policy_documents = data.aws_iam_policy_document.bucket_policy.*.json
}

resource "aws_s3_bucket_policy" "default" {
  count      = module.this.enabled && (var.allow_ssl_requests_only || var.allow_encrypted_uploads_only || var.policy != "") ? 1 : 0
  bucket     = join("", aws_s3_bucket.default.*.id)
  policy     = join("", data.aws_iam_policy_document.aggregated_policy.*.json)
  depends_on = [aws_s3_bucket_public_access_block.default]
}

# Refer to the terraform documentation on s3_bucket_public_access_block at
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
# for the nuances of the blocking options
resource "aws_s3_bucket_public_access_block" "default" {
  count  = module.this.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Per https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
# It is safe to always set to BucketOwnerPreferred. The bucket owner will own the object
# if the object is uploaded with the bucket-owner-full-control canned ACL. Without
# this setting and canned ACL, the object is uploaded and remains owned by the uploading account.
resource "aws_s3_bucket_ownership_controls" "default" {
  count  = module.this.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [time_sleep.wait_for_aws_s3_bucket_settings]
}

# Workaround S3 eventual consistency for settings objects
resource "time_sleep" "wait_for_aws_s3_bucket_settings" {
  count            = module.this.enabled ? 1 : 0
  depends_on       = [aws_s3_bucket_public_access_block.default, aws_s3_bucket_policy.default]
  create_duration  = "30s"
  destroy_duration = "30s"
}
