variable "name" {}
variable "namespage" {}
variable "stage" {}

variable "tags" {
  default = {}
}

variable "acl" {
  default = "log-delivery-write"
}

variable "prefix" {
  default = ""
}

variable "standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the glacier tier"
  default     = "30"
}

variable "glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "90"
}
