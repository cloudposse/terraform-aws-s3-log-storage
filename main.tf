locals {
  # We do not use coalesce() here because it is OK if local.bucket_name is empty.
  bucket_name = var.bucket_name == null || var.bucket_name == "" ? module.bucket_name.id : var.bucket_name
}

module "bucket_name" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.enabled && try(length(var.bucket_name) == 0, false)

  id_length_limit = 63 # https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

  context = module.this.context
}


module "aws_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.3"

  bucket_name        = local.bucket_name
  acl                = var.acl
  grants             = var.grants
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

  object_lock_configuration = var.object_lock_configuration

  context = module.this.context
}
