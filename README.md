# tf_log_storage

This module creates an S3 bucket suitable for receiving logs from other AWS services such as S3, CloudFront, and CloudTrails, which generate an enormous amount of log data. It implements a configurable log retention policy, which allows you to efficiently manage logs across different storage classes (E.g. glacier) and ultimately expire the data altogether.


## Usage

```terraform
module "log_storage" {
  source                   = "git::https://github.com/cloudposse/tf_log_storage.git?ref=master"
  name                     = "${var.name}"
  stage                    = "${var.stage}"
  namespace                = "${var.namespace}"
  acl                      = "${var.acl}"
  prefix                   = "${var.prefix}"
  standard_transition_days = "${var.standard_transition_days}"
  glacier_transition_days  = "${var.glacier_transition_days}"
  expiration_days          = "${var.expiration_days}"
}
```


## Variables
|  Name                               |  Default            |  Description                                                                            | Required |
|:------------------------------------|:-------------------:|:----------------------------------------------------------------------------------------|:--------:|
| `namespace`                         | ``                  | Namespace (e.g. `cp` or `cloudposse`)                                                   | Yes      |
| `stage`                             | ``                  | Stage (e.g. `prod`, `dev`, `staging`)                                                   | Yes      |
| `name`                              | ``                  | Name  (e.g. `log`)                                                                      | Yes      |
| `acl`                               | `log-delivery-write`| The canned ACL to apply                                                                 | No       |
| `policy`                            | ``                  | A valid bucket policy JSON document                                                     | No       |
| `prefix`                            | ``                  | Object key prefix identifying one or more objects to which the lifecycle rule applies   | No       |
| `region`                            | ``                  | If specified, the AWS region this bucket should reside in. Defaults to region of callee.| No       |
| `force_destroy`                     | ``                  | All objects will be forcefully deleted from the bucket when bucket destroyed            | No       |
| `lifecycle_rule_enabled`            | `true`              | Enable object lifecycle rules on this bucket                                            | No       |
| `versioning_enabled`                | `false`             | Versioning is a means of keeping multiple variants of an object in the same bucket      | No       |
| `noncurrent_version_transition_days`| `30`                | Number of days to persist in the standard storage tier before moving to the glacier tier| No       |
| `noncurrent_version_expiration_days`| `90`                | Specifies when noncurrent object versions expire                                        | No       |
| `standard_transition_days`          | `30`                | Number of days to persist in the standard storage tier before moving to the glacier tier| No       |
| `glacier_transition_days`           | `60`                | Number of days after which to move the data to the glacier storage tier                 | No       |
| `expiration_days`                   | `90`                | Number of days after which to expunge the objects                                       | No       |

## Outputs

| Name                  | Description                           |
|:----------------------|:--------------------------------------|
| `bucket_domain_name`  | FQDN of bucket                        |
| `bucket_id`           | Bucket Name (aka ID)                  |
| `bucket_arn`          | Bucket ARN                            |
| `prefix`              | Prefix configured for lifecycle rules |
