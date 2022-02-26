provider "aws" {
  region = var.region
}

module "s3_log_storage" {
  source                = "../../"
  force_destroy         = true
  force_destroy_enabled = true

  lifecycle_configuration_rules = var.lifecycle_configuration_rules

  context = module.this.context
}
