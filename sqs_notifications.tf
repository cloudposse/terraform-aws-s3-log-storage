locals {
  sqs_notifications_enabled = module.this.enabled && var.bucket_notifications_enabled && (var.bucket_notifications_type == "SQS")
  sqs_queue_name            = module.this.id
}

resource "aws_sqs_queue" "notifications" {
  count  = local.sqs_notifications_enabled ? 1 : 0
  name   = local.sqs_queue_name
  policy = join("", data.aws_iam_policy_document.sqs.*.json)
  tags   = module.this.tags
}

data "aws_iam_policy_document" "sqs" {
  count = local.sqs_notifications_enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = aws_sqs_queue.notifications.*.arn
    actions = [
      "sqs:SendMessage"
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = aws_s3_bucket.default.*.arn
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = local.sqs_notifications_enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  queue {
    queue_arn = join("", aws_sqs_queue.notifications.*.arn)
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = var.bucket_notifications_prefix
  }
}
