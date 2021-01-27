provider "aws" {
  region = var.region
}

module "s3_log_storage" {
  source        = "../../"
  mfa_delete    = false
  force_destroy = true

  context = module.this.context
}
