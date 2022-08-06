# ------------------------------------------------------------------------------
# KMS Key Policy Meta
# ------------------------------------------------------------------------------
module "s3_bucket_kms_key_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.s3_log_storage_meta.context
  enabled = var.create_kms_key && module.this.enabled
}


# ------------------------------------------------------------------------------
# KMS Key Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key" {
  count = module.s3_log_storage_meta.enabled ? 1 : 0
  #  source_policy_documents = [var.kms_key_policy_source_json]
  statement {
    sid = "Allow GuardDuty to encrypt findings"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow all users to modify/delete key (test only)"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

}


# ------------------------------------------------------------------------------
# KMS Key Policy
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "registry.terraform.io/cloudposse/kms-key/aws"
  version = "0.12.1"
  context = module.s3_log_storage_meta.context

  description             = "KMS key for S3"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = join("", data.aws_iam_policy_document.kms_key.*.json)
}
