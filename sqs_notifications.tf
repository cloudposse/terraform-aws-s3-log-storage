locals {
  enabled                   = module.this.enabled
  sqs_notifications_enabled = local.enabled && var.bucket_notifications_enabled && var.bucket_notifications_type == "SQS"
  sqs_queue_name            = module.this.id
  partition                 = join("", data.aws_partition.current[*].partition)
}

data "aws_caller_identity" "current" { count = local.enabled ? 1 : 0 }
data "aws_partition" "current" { count = local.enabled ? 1 : 0 }

resource "aws_sqs_queue" "notifications" {
  #bridgecrew:skip=BC_AWS_GENERAL_16:Skipping `AWS SQS server side encryption is not enabled` check because this queue does not have sensitive data. Enabling the encryption for S3 publisher requires the new CMK which is extra here.
  count  = local.sqs_notifications_enabled ? 1 : 0
  name   = local.sqs_queue_name
  policy = join("", data.aws_iam_policy_document.sqs_policy[*].json)
  tags   = module.this.tags
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/grant-destinations-permissions-to-s3.html
data "aws_iam_policy_document" "sqs_policy" {
  count = local.sqs_notifications_enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = ["arn:${local.partition}:sqs:*:*:${local.sqs_queue_name}"]
    actions = [
      "sqs:SendMessage"
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = module.aws_s3_bucket.bucket_arn
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
      join("", data.aws_caller_identity.current[*].account_id)]
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = local.sqs_notifications_enabled ? 1 : 0
  bucket = join("", module.aws_s3_bucket.bucket_id)

  queue {
    queue_arn = join("", aws_sqs_queue.notifications[*].arn)
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = var.bucket_notifications_prefix
  }
}
