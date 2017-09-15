module "log_storage" {
  source             = "../"
  name               = "eg"
  stage              = "test"
  namespace          = "example"
  versioning_enabled = "true"
}
