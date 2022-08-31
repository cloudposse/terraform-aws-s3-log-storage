
# Terraform prior to 1.1 does not support a `moved` block.
# Terraform 1.1 supports `moved` blocks in general, but does not a support
# a move to an object declared in external module package.
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

locals {
  # This is a big hack to enable us to generate something close to a custom error message
  force_destroy_error_message = <<-EOT

    ** ERROR: You must set `force_destroy_enabled = true` to enable `force_destroy`. **n/
    ** WARNING: Upgrading this module from a version prior to 0.27.0 to this version **n/
    **  will cause Terraform to delete your existing S3 bucket CAUSING COMPLETE DATA LOSS **n/
    **  unless you follow the upgrade instructions on the Wiki [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.27.0-(POTENTIAL-DATA-LOSS)). **n/
    **  See additional instructions for upgrading from v0.27.0 to v0.28.0 [here](https://github.com/cloudposse/terraform-aws-s3-log-storage/wiki/Upgrading-to-v0.28.0-and-AWS-provider-v4-(POTENTIAL-DATA-LOSS)). **n/

    EOT
  force_destroy_safety = {
    true = {
      true  = "true"
      false = "false"
    },
    false = {
      true  = local.force_destroy_error_message
      false = "false"
    }
  }
  # Generate an error message when `force_destroy == true && force_destroy_enabled == false`
  force_destroy = tobool(local.force_destroy_safety[var.force_destroy_enabled][var.force_destroy])

  bucket_name = var.bucket_name == null || var.bucket_name == "" ? module.this.id : var.bucket_name
}

module "aws_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.1"

  bucket_name        = local.bucket_name
  acl                = var.acl
  force_destroy      = local.force_destroy
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
