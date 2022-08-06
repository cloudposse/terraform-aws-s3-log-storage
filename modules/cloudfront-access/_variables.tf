variable "create_kms_key" {
  type = bool
  default = false
}

variable "lifecycle_configuration_rules" {
  type    = any
  default = []
}

variable "force_destroy" {
  type    = bool
  default = false
}

#variable "kms_key_policy_source_json" {
#  type    = string
#  default = ""
#}

variable "access_log_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the S3 bucket where S3 access logs will be sent to"
}

variable "access_log_bucket_prefix_override" {
  type        = string
  default     = ""
  description = "Prefix to prepend to the current S3 bucket name, where S3 access logs will be sent to"
}
