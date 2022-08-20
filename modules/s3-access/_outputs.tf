output "bucket_id" {
  value = module.s3_log_storage.bucket_id
}

output "bucket_arn" {
  value = module.s3_log_storage.bucket_arn
}

output "bucket_fqdn" {
  value = module.s3_log_storage.bucket_domain_name
}
