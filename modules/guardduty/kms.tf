# ------------------------------------------------------------------------------
# KMS Key Policy Context
# ------------------------------------------------------------------------------
module "kms_key_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "1.0.2"
  context = module.s3_log_storage_context.self
  enabled = var.create_kms_key && module.context.enabled
}


# ------------------------------------------------------------------------------
# KMS Key Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key" {
  count = module.kms_key_context.enabled ? 1 : 0

  statement {
    sid    = "AwsRootAccess"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:Tag*",
      "kms:Untag*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    #bridgecrew:skip=CKV_AWS_109:This policy applies only to the key it is attached to
    #bridgecrew:skip=CKV_AWS_111:This policy applies only to the key it is attached to
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = ["${local.arn_prefix}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Allow GuardDuty to encrypt findings"
    actions = ["kms:GenerateDataKey"]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
}


# ------------------------------------------------------------------------------
# KMS Key Policy
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "app.terraform.io/SevenPico/kms-key/aws"
  version = "0.12.1.2"
  context = module.kms_key_context.self

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  description              = "KMS key for S3"
  enable_key_rotation      = var.kms_key_enable_key_rotation
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = join("", data.aws_iam_policy_document.kms_key.*.json)
}
