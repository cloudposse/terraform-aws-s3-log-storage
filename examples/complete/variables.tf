variable "region" {
  type = string
}

variable "allow_ssl_requests_only" {
  type        = bool
  default     = true
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = optional(object({
      object_size_greater_than = optional(number) # integer >= 0
      object_size_less_than    = optional(number) # integer >= 1
      prefix                   = optional(string)
      tags                     = optional(map(string))
    }))
    expiration = optional(object({
      date                         = optional(string) # string, RFC3339 time format, GMT
      days                         = optional(number) # integer > 0
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number) # integer > 0
      noncurrent_days           = optional(number) # integer >= 0
    }))
    transition = optional(list(object({
      date          = optional(string) # string, RFC3339 time format, GMT
      days          = optional(number) # integer >= 0
      storage_class = string           # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])
    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number) # integer >= 0
      noncurrent_days           = optional(number) # integer >= 0
      storage_class             = string           # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])
  }))

  description = <<-EOT
    A list of S3 bucket v2 lifecycle rules, as specified in [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)"
    These rules are not affected by the deprecated `lifecycle_rule_enabled` flag.
    **NOTE:** Unless you also set `lifecycle_rule_enabled = false` you will also get the default deprecated rules set on your bucket.
    EOT
  default     = []
  nullable    = false
}
