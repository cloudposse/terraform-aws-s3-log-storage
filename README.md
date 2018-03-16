# terraform-aws-s3-log-storage [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-s3-log-storage.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-s3-log-storage)

This module creates an S3 bucket suitable for receiving logs from other `AWS` services such as `S3`, `CloudFront`, and `CloudTrails`.

It implements a configurable log retention policy, which allows you to efficiently manage logs across different storage classes (_e.g._ `Glacier`) and ultimately expire the data altogether.

It enables server-side default encryption.

https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html


## Usage

```hcl
module "log_storage" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-s3-log-storage.git?ref=master"
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
|  Name                               |  Default            |  Description                                                                                       | Required |
|:------------------------------------|:-------------------:|:---------------------------------------------------------------------------------------------------|:--------:|
| `namespace`                         | ``                  | Namespace (e.g. `cp` or `cloudposse`)                                                              | Yes      |
| `stage`                             | ``                  | Stage (e.g. `prod`, `dev`, `staging`)                                                              | Yes      |
| `name`                              | ``                  | Name  (e.g. `log`)                                                                                 | Yes      |
| `attributes`                        | `[]`                | Additional attributes (e.g. `policy` or `role`)                                                    | No       |
| `tags`                              | `{}`                | Additional tags  (e.g. `map("BusinessUnit","XYZ")`                                                 | No       |
| `acl`                               | `log-delivery-write`| The canned ACL to apply                                                                            | No       |
| `policy`                            | ``                  | A valid bucket policy JSON document                                                                | No       |
| `prefix`                            | ``                  | Object key prefix identifying one or more objects to which the lifecycle rule applies              | No       |
| `region`                            | ``                  | If specified, the AWS region this bucket should reside in. Defaults to region of callee.           | No       |
| `force_destroy`                     | ``                  | All objects will be forcefully deleted from the bucket when bucket destroyed                       | No       |
| `lifecycle_rule_enabled`            | `true`              | Enable object lifecycle rules on this bucket                                                       | No       |
| `versioning_enabled`                | `false`             | Versioning is a means of keeping multiple variants of an object in the same bucket                 | No       |
| `noncurrent_version_transition_days`| `30`                | Number of days to persist in the standard storage tier before moving to the glacier tier           | No       |
| `noncurrent_version_expiration_days`| `90`                | Specifies when noncurrent object versions expire                                                   | No       |
| `standard_transition_days`          | `30`                | Number of days to persist in the standard storage tier before moving to the infrequent access tier | No       |
| `glacier_transition_days`           | `60`                | Number of days after which to move the data to the glacier storage tier                            | No       |
| `expiration_days`                   | `90`                | Number of days after which to expunge the objects                                                  | No       |
| `sse_algorithm`                     | `AES256`            | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`               | No       |
| `kms_master_key_id`                 | ``                  | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default AWS/S3 AWS KMS master key is used if this element is absent while the sse_algorithm is `aws:kms`  | No       |


## Outputs

| Name                  | Description                           |
|:----------------------|:--------------------------------------|
| `bucket_domain_name`  | FQDN of bucket                        |
| `bucket_id`           | Bucket Name (aka ID)                  |
| `bucket_arn`          | Bucket ARN                            |
| `prefix`              | Prefix configured for lifecycle rules |



## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-s3-log-storage/issues), send us an [email](mailto:hello@cloudposse.com) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-s3-log-storage/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing `terraform-aws-s3-log-storage`, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

**NOTE:** Be sure to merge the latest from "upstream" before making a pull request!


## License

[APACHE 2.0](LICENSE) © 2018 [Cloud Posse, LLC](https://cloudposse.com)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## About

`terraform-aws-s3-log-storage` is maintained and funded by [Cloud Posse, LLC][website].

![Cloud Posse](https://cloudposse.com/logo-300x69.png)


Like it? Please let us know at <hello@cloudposse.com>

We love [Open Source Software](https://github.com/cloudposse/)!

See [our other projects][community]
or [hire us][hire] to help build your next cloud platform.

  [website]: https://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: https://cloudposse.com/contact/


### Contributors

| [![Erik Osterman][erik_img]][erik_web]<br/>[Erik Osterman][erik_web] | [![Andriy Knysh][andriy_img]][andriy_web]<br/>[Andriy Knysh][andriy_web] |
|-------------------------------------------------------|------------------------------------------------------------------|

  [erik_img]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144
  [erik_web]: https://github.com/osterman/
  [andriy_img]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [andriy_web]: https://github.com/aknysh/
