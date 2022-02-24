provider "aws" {
  region = var.region
}

module "s3_log_storage" {
  source        = "../../"
  force_destroy = false

  context = module.this.context
}
