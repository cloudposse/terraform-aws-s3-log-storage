output "bucket_domain_name" {
  value       = module.s3_log_storage.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = module.s3_log_storage.bucket_id
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.s3_log_storage.bucket_arn
  description = "Bucket ARN"
}
