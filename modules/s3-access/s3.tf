# ------------------------------------------------------------------------------
# S3 Log Storage Labels
# ------------------------------------------------------------------------------
module "s3_log_storage_meta" {
  source     = "registry.terraform.io/cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["s3-access-logs"]
}


# ------------------------------------------------------------------------------
# S3 Log Storage
# ------------------------------------------------------------------------------
module "s3_log_storage" {
  source  = "../../"
  context = module.s3_log_storage_meta.context

  access_log_bucket_name            = var.access_log_to_self ? null : var.access_log_bucket_name
  access_log_bucket_prefix_override = var.access_log_bucket_prefix_override
  acl                               = "log-delivery-write"
  allow_encrypted_uploads_only      = false
  allow_ssl_requests_only           = true
  block_public_acls                 = true
  block_public_policy               = true
  bucket_key_enabled                = false
  bucket_name                       = null
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

resource "aws_s3_bucket_logging" "self" {
  count      = module.s3_log_storage_meta.enabled && var.access_log_to_self ? 1 : 0
  depends_on = [module.s3_log_storage]


  bucket        = length(module.s3_log_storage.bucket_id) > 0 ? module.s3_log_storage.bucket_id : "abc"
  target_bucket = length(module.s3_log_storage.bucket_id) > 0 ? module.s3_log_storage.bucket_id : "abc"
  target_prefix = var.access_log_bucket_prefix_override == null || var.access_log_bucket_prefix_override == "" ? "${module.s3_log_storage_meta.id}/" : "${var.access_log_bucket_prefix_override}/"
}
