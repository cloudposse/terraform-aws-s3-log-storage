
# Terraform prior to 1.1 does not support a `moved` block.
# Terraform 1.1 supports `moved` blocks in general, but does not a support
# a move to an object declared in external module package.
# These `moved` blocks require Terraform 1.3.0 or later.

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
moved {
  from = time_sleep.wait_for_aws_s3_bucket_settings
  to   = module.aws_s3_bucket.time_sleep.wait_for_aws_s3_bucket_settings
}

locals {
  # We do not use coalesce() here because it is OK if local.bucket_name is empty.
  bucket_name = var.bucket_name == null || var.bucket_name == "" ? module.this.id : var.bucket_name
}

module "aws_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.0.0"

  bucket_name        = local.bucket_name
  acl                = var.acl
  force_destroy      = var.force_destroy
  versioning_enabled = var.versioning_enabled

  source_policy_documents = var.source_policy_documents
  # Support deprecated `policy` input
  policy = var.policy

  lifecycle_configuration_rules = var.lifecycle_configuration_rules
  # Support deprecated lifecycle inputs
  lifecycle_rule_ids = local.deprecated_lifecycle_rule.enabled ? [module.this.id] : null
  lifecycle_rules    = local.deprecated_lifecycle_rule.enabled ? [local.deprecated_lifecycle_rule] : null

  logging = var.access_log_bucket_name == "" ? null : {
    bucket_name = var.access_log_bucket_name
    prefix      = "${var.access_log_bucket_prefix}${local.bucket_name}/"
  }

  sse_algorithm      = var.sse_algorithm
  kms_master_key_arn = var.kms_master_key_arn
  bucket_key_enabled = var.bucket_key_enabled

  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  s3_object_ownership = var.s3_object_ownership

  context = module.this.context
}
