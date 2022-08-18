output "bucket_domain_name" {
  value       = module.aws_s3_bucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = module.context.id #module.aws_s3_bucket.bucket_id #FIXME - this could be bad if bucket name is overwritten
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.aws_s3_bucket.bucket_arn
  description = "Bucket ARN"
}

output "bucket_notifications_sqs_queue_arn" {
  value       = join("", aws_sqs_queue.notifications.*.arn)
  description = "Notifications SQS queue ARN"
}

output "enabled" {
  value       = module.context.enabled
  description = "Is module enabled"
}
