# ------------------------------------------------------------------------------
# S3 Bucket Labels
# ------------------------------------------------------------------------------
module "s3_bucket_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
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
  kms_master_key_arn                = ""
  lifecycle_configuration_rules     = var.lifecycle_configuration_rules
  restrict_public_buckets           = true
  s3_object_ownership               = "BucketOwnerEnforced"
  source_policy_documents           = []
  sse_algorithm                     = "AES256"
  versioning_enabled                = true
}

resource "aws_s3_bucket_logging" "s3_access_logs" {
  count  = module.s3_bucket_meta.enabled ? 1 : 0
  bucket = module.s3_bucket.bucket_id

  target_bucket = module.s3_bucket.bucket_id
  target_prefix = module.s3_bucket_meta.id
}
