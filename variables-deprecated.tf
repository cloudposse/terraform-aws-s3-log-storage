variable "policy" {
  type        = string
  description = "(Deprecated, use `source_policy_documents` instead): A valid bucket policy JSON document."
  default     = ""
}

variable "lifecycle_rule_enabled" {
  type        = bool
  default     = true
  description = <<-EOF
    DEPRECATED: Defaults to `true`, **please set to `false`** and use `lifecycle_configuration_rules` instead.
    When `true`, configures lifecycle events on this bucket using individual (now deprecated) variables."
    EOF
}

variable "lifecycle_prefix" {
  type        = string
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nPrefix filter. Used to manage object lifecycle events"
  default     = ""
}

variable "lifecycle_tags" {
  type        = map(string)
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nTags filter. Used to manage object lifecycle events"
  default     = {}
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  default     = 5
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nMaximum time (in days) that you want to allow multipart uploads to remain in progress"
}

variable "enable_glacier_transition" {
  type        = bool
  default     = true
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nEnables the transition to AWS Glacier which can cause unnecessary costs for huge amount of small files"
}

variable "enable_noncurrent_version_expiration" {
  type        = bool
  default     = true
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nEnable expiration of non-current versions"
}

variable "expiration_days" {
  type        = number
  default     = 90
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days after which to expunge the objects"
}

variable "standard_transition_days" {
  type        = number
  default     = 30
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days to persist in the standard storage tier before moving to the infrequent access tier"
}

variable "glacier_transition_days" {
  type        = number
  default     = 60
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days after which to move the data to the Glacier Flexible Retrieval storage tier"
}

variable "noncurrent_version_transition_days" {
  type        = number
  default     = 30
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nSpecifies (in days) when noncurrent object versions transition to Glacier Flexible Retrieval"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 90
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nSpecifies when non-current object versions expire (in days)"
}



locals {
  deprecated_lifecycle_rule = {
    enabled = var.lifecycle_rule_enabled
    prefix  = var.lifecycle_prefix
    tags    = var.lifecycle_tags

    abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days

    enable_glacier_transition            = var.enable_glacier_transition
    enable_deeparchive_transition        = false
    enable_standard_ia_transition        = true
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = var.enable_noncurrent_version_expiration

    expiration_days             = var.expiration_days
    standard_transition_days    = var.standard_transition_days
    glacier_transition_days     = var.glacier_transition_days
    deeparchive_transition_days = null

    noncurrent_version_glacier_transition_days     = var.noncurrent_version_transition_days
    noncurrent_version_deeparchive_transition_days = null
    noncurrent_version_expiration_days             = var.noncurrent_version_expiration_days
  }
}
