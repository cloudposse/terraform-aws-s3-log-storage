# ------------------------------------------------------------------------------
# S3 Bucket KMS Key Policy Meta
# ------------------------------------------------------------------------------
module "s3_bucket_kms_key_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.s3_bucket_meta.context
  enabled = var.create_kms_key && module.this.enabled
}


# ------------------------------------------------------------------------------
# S3 Bucket KMS Key Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key" {
  count                   = module.s3_bucket_kms_key_meta.enabled ? 1 : 0
  source_policy_documents = [var.kms_key_policy_source_json]
  statement {
    sid    = "Enable Root User Permissions"
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
    resources = [
      "*"
    ]
    principals {
      type = "AWS"

      identifiers = [
        "${local.arn_format}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
  statement {
    sid    = "Allow VPC Flow Logs to use the key"
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*"
    ]
    principals {
      type = "Service"

      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}


# ------------------------------------------------------------------------------
# S3 Bucket KMS Key
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "registry.terraform.io/cloudposse/kms-key/aws"
  version = "0.12.1"
  context = module.s3_bucket_kms_key_meta.context

  description             = "KMS key for AWS VPC Flow Log Delivery"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = join("", data.aws_iam_policy_document.kms_key.*.json)
}
