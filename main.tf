locals {
  lifecycle_rule = {
    enabled = var.lifecycle_rule_enabled
    prefix  = var.lifecycle_prefix
    tags    = var.lifecycle_tags

    abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days

    enable_glacier_transition            = var.enable_glacier_transition
    enable_deeparchive_transition        = false
    enable_standard_ia_transition        = true
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = var.enable_noncurrent_version_expiration

    noncurrent_version_glacier_transition_days     = var.noncurrent_version_transition_days
    noncurrent_version_deeparchive_transition_days = null
    noncurrent_version_expiration_days             = var.noncurrent_version_expiration_days

    standard_transition_days    = var.standard_transition_days
    glacier_transition_days     = var.glacier_transition_days
    deeparchive_transition_days = null
    expiration_days             = var.expiration_days
  }
}

# Terraform prior to 1.1 does not support a `moved` block.
# Terraform 1.1 does not a support move to an object declared in external module package.
# Leaving this here for documentation and in case Terraform later supports it.
/*
moved {
  from = aws_s3_bucket.default
  to   = module.aws_s3_bucket.aws_s3_bucket.default
}
moved {
  from = aws_s3_bucket_policy.default
  to   = module.aws_s3_bucket.aws_s3_bucket_policy.default
}
moved {
  from = aws_s3_bucket_ownership_controls.default
  to   = module.aws_s3_bucket.aws_s3_bucket_ownership_controls.default
}
moved {
  from = aws_s3_bucket_public_access_block.default
  to   = module.aws_s3_bucket.aws_s3_bucket_public_access_block.default
}
*/

module "aws_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.48.0"

  bucket_name        = module.this.id
  acl                = var.acl
  force_destroy      = var.force_destroy
  policy             = var.policy
  versioning_enabled = var.versioning_enabled

  lifecycle_rules = [local.lifecycle_rule]

  logging = var.access_log_bucket_name == "" ? null : {
    bucket_name = var.access_log_bucket_name
    prefix      = "${var.access_log_bucket_prefix}${module.this.id}/"
  }

  sse_algorithm      = var.sse_algorithm
  kms_master_key_arn = var.kms_master_key_arn

  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  s3_object_ownership = "BucketOwnerPreferred"

  context = module.this.context
}
