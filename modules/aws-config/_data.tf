locals {
  arn_format = "arn:${data.aws_partition.current.partition}"
}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "default" {
  count = module.context.enabled ? 1 : 0
}

