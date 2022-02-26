variable "region" {
  type = string
}

variable "allow_ssl_requests_only" {
  type        = bool
  default     = true
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
}

variable "lifecycle_configuration_rules" {
  type        = any
  default     = null
  description = "Bucket lifecycle rules"
}
