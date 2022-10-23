variable "policy" {
  type        = string
  description = "(Deprecated, use `source_policy_documents` instead): A valid bucket policy JSON document."
  default     = null
}

variable "lifecycle_rule_enabled" {
  type        = bool
  description = <<-EOF
    DEPRECATED: Use `lifecycle_configuration_rules` instead.
    When `true`, configures lifecycle events on this bucket using individual (now deprecated) variables.
    When `false`, lifecycle events are not configured using individual (now deprecated) variables, but `lifecycle_configuration_rules` still apply.
    When `null`, lifecycle events are configured using individual (now deprecated) variables only if `lifecycle_configuration_rules` is empty.
    EOF
  default     = null
}

variable "lifecycle_prefix" {
  type        = string
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nPrefix filter. Used to manage object lifecycle events"
  default     = null
}

variable "lifecycle_tags" {
  type        = map(string)
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nTags filter. Used to manage object lifecycle events"
  default     = null
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nMaximum time (in days) that you want to allow multipart uploads to remain in progress"
  default     = null
}

variable "enable_glacier_transition" {
  type        = bool
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nEnables the transition to AWS Glacier which can cause unnecessary costs for huge amount of small files"
  default     = null
}

variable "enable_noncurrent_version_expiration" {
  type        = bool
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nEnable expiration of non-current versions"
  default     = null
}

variable "expiration_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days after which to expunge the objects"
  default     = null
}

variable "standard_transition_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days to persist in the standard storage tier before moving to the infrequent access tier"
  default     = null
}

variable "glacier_transition_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nNumber of days after which to move the data to the Glacier Flexible Retrieval storage tier"
  default     = null
}

variable "noncurrent_version_transition_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nSpecifies (in days) when noncurrent object versions transition to Glacier Flexible Retrieval"
  default     = null
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "(Deprecated, use `lifecycle_configuration_rules` instead)\nSpecifies when non-current object versions expire (in days)"
  default     = null
}



locals {
  deprecated_lifecycle_rule = {
    enabled = var.lifecycle_rule_enabled == true || (var.lifecycle_rule_enabled == null && length(var.lifecycle_configuration_rules) == 0)
    prefix  = var.lifecycle_prefix
    tags    = var.lifecycle_tags

    abort_incomplete_multipart_upload_days = coalesce(var.abort_incomplete_multipart_upload_days, 5)

    enable_glacier_transition            = coalesce(var.enable_glacier_transition, true)
    enable_deeparchive_transition        = false
    enable_standard_ia_transition        = true
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = coalesce(var.enable_noncurrent_version_expiration, true)

    expiration_days             = coalesce(var.expiration_days, 90)
    standard_transition_days    = coalesce(var.standard_transition_days, 30)
    glacier_transition_days     = coalesce(var.glacier_transition_days, 60)
    deeparchive_transition_days = null

    noncurrent_version_glacier_transition_days     = coalesce(var.noncurrent_version_transition_days, 30)
    noncurrent_version_deeparchive_transition_days = null
    noncurrent_version_expiration_days             = coalesce(var.noncurrent_version_expiration_days, 90)
  }
}
