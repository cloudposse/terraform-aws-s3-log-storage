# The AWS region currently being used.
data "aws_region" "current" {
}

# The AWS account id
data "aws_caller_identity" "current" {
}

# The AWS partition (commercial or govcloud)
data "aws_partition" "current" {}

locals {
  arn_prefix = "arn:${data.aws_partition.current.partition}"
}

data "aws_elb_service_account" "default" {
  count = module.context.enabled ? 1 : 0
}

