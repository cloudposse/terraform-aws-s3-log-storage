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
|  Name                     |  Default            |  Description                                                                            | Required |
|:--------------------------|:-------------------:|:----------------------------------------------------------------------------------------|:--------:|
| `namespace`               | ``                  | Namespace (e.g. `cp` or `cloudposse`)                                                   | Yes      |
| `stage`                   | ``                  | Stage (e.g. `prod`, `dev`, `staging`)                                                   | Yes      |
| `name`                    | ``                  | Name  (e.g. `log`)                                                                      | Yes      |
| `acl`                     | `log-delivery-write`| The canned ACL to apply                                                                 | Np       |
| `prefix`                  | ``                  | Object key prefix identifying one or more objects to which the rule applies.            | Yes      |
| `standard_transition_days`| `30`                | Number of days to persist in the standard storage tier before moving to the glacier tier| No       |
| `glacier_transition_days` | `60`                | Number of days after which to move the data to the glacier storage tier                 | No       |
| `glacier_transition_days` | `90`                | Number of days after which to expunge the objects                                       | No       |



## Outputs

| Name                  | Description               |
|:----------------------|:--------------------------|
| `bucket_domain_name`  | Domain name of bucket     |
| `bucket_id`           | ID of bucket              |
