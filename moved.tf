
# Terraform prior to 1.1 does not support a `moved` block.
# Terraform 1.1 supports `moved` blocks in general, but does not support
# a move to an object declared in external module package.
# These `moved` blocks require Terraform 1.3.0 or later.

moved {
  from = aws_s3_bucket.default
  to   = module.aws_s3_bucket.aws_s3_bucket.default
}
moved {
  from = aws_s3_bucket_policy.default
  to   = module.aws_s3_bucket.aws_s3_bucket_policy.default
}
moved {
  from = aws_s3_bucket_ownership_controls.default
  to   = module.aws_s3_bucket.aws_s3_bucket_ownership_controls.default
}
moved {
  from = aws_s3_bucket_public_access_block.default
  to   = module.aws_s3_bucket.aws_s3_bucket_public_access_block.default
}
moved {
  from = time_sleep.wait_for_aws_s3_bucket_settings
  to   = module.aws_s3_bucket.time_sleep.wait_for_aws_s3_bucket_settings
}

