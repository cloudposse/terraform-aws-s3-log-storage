


locals {
  bucket_name = var.bucket_name == null || var.bucket_name == "" ? module.this.id : var.bucket_name
}

module "aws_s3_bucket" {
  source  = "app.terraform.io/SevenPico/s3-bucket/aws"
  version = "2.0.3.2"
  context = module.this.context

  acl                          = var.acl
  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only
  allowed_bucket_actions = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]
  block_public_acls             = var.block_public_acls
  block_public_policy           = var.block_public_policy
  bucket_key_enabled            = false
  bucket_name                   = local.bucket_name
  cors_rule_inputs              = null
  force_destroy                 = var.force_destroy
  grants                        = []
  ignore_public_acls            = var.ignore_public_acls
  kms_master_key_arn            = var.kms_master_key_arn
  lifecycle_configuration_rules = var.lifecycle_configuration_rules
  logging = var.access_log_bucket_name != null ? {
    bucket_name = var.access_log_bucket_name
    prefix      = var.access_log_bucket_prefix_override == null || var.access_log_bucket_prefix_override == "" ? "${module.this.id}/" : "${var.access_log_bucket_prefix_override}/"
  } : {}
  object_lock_configuration     = null
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  restrict_public_buckets       = var.restrict_public_buckets
  s3_object_ownership           = "BucketOwnerPreferred"
  s3_replica_bucket_arn         = ""
  s3_replication_enabled        = false
  s3_replication_rules          = null
  s3_replication_source_roles   = []
  source_policy_documents       = []
  sse_algorithm                 = var.sse_algorithm
  transfer_acceleration_enabled = false
  user_enabled                  = false
  versioning_enabled            = var.versioning_enabled
  website_inputs                = null
}

