region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-log-storage"

allow_ssl_requests_only = true

lifecycle_configuration_rules = [
  {
    enabled = true # bool
    id      = "v2rule"

    abort_incomplete_multipart_upload_days = 1 # number

    filter_and = null
    expiration = null
    transition = null
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 3  # integer > 0
      noncurrent_days           = 90 # integer >= 0
    }
    noncurrent_version_transition = [{
      newer_noncurrent_versions = 3            # integer >= 0
      noncurrent_days           = 30           # integer >= 0
      storage_class             = "ONEZONE_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
  }
]
