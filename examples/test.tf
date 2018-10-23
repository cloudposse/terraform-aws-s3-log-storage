module "log_storage" {
  source             = "../"
  enabled            = "true"
  name               = "eg"
  stage              = "test"
  namespace          = "example"
  versioning_enabled = "true"
}
