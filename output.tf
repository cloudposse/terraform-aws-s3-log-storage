output "bucket_domain_name" {
  value       = "${aws_s3_bucket.default.bucket_domain_name}"
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = "${aws_s3_bucket.default.id}"
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = "${aws_s3_bucket.default.arn}"
  description = "Bucket ARN"
}

output "prefix" {
  value       = "${var.prefix}"
  description = "Prefix configured for lifecycle rules"
}
