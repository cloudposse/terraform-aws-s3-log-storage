## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acl | The canned ACL to apply. We recommend log-delivery-write for compatibility with AWS services | string | `log-delivery-write` | no |
| attributes | Additional attributes (e.g. `policy` or `role`) | list(string) | `<list>` | no |
| block_public_acls | Set to `false` to disable the blocking of new public access lists on the bucket | bool | `true` | no |
| block_public_policy | Set to `false` to disable the blocking of new public policies on the bucket | bool | `true` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| enable_glacier_transition | Enables the transition to AWS Glacier which can cause unnecessary costs for huge amount of small files | bool | `true` | no |
| enabled | Set to `false` to prevent the module from creating any resources | bool | `true` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | string | `` | no |
| expiration_days | Number of days after which to expunge the objects | number | `90` | no |
| force_destroy | (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | bool | `false` | no |
| glacier_transition_days | Number of days after which to move the data to the glacier storage tier | number | `60` | no |
| ignore_public_acls | Set to `false` to disable the ignoring of public access lists on the bucket | bool | `true` | no |
| kms_master_key_arn | The AWS KMS master key ARN used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms | string | `` | no |
| lifecycle_prefix | Prefix filter. Used to manage object lifecycle events | string | `` | no |
| lifecycle_rule_enabled | Enable lifecycle events on this bucket | bool | `true` | no |
| lifecycle_tags | Tags filter. Used to manage object lifecycle events | map(string) | `<map>` | no |
| name | Name  (e.g. `app` or `db`) | string | - | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `` | no |
| noncurrent_version_expiration_days | Specifies when noncurrent object versions expire | number | `90` | no |
| noncurrent_version_transition_days | Specifies when noncurrent object versions transitions | number | `30` | no |
| policy | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | string | `` | no |
| region | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee | string | `` | no |
| restrict_public_buckets | Set to `false` to disable the restricting of making the bucket public | bool | `true` | no |
| sse_algorithm | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | string | `AES256` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |
| standard_transition_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier | number | `30` | no |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`) | map(string) | `<map>` | no |
| versioning_enabled | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_arn | Bucket ARN |
| bucket_domain_name | FQDN of bucket |
| bucket_id | Bucket Name (aka ID) |
| enabled | Is module enabled |
| prefix | Prefix configured for lifecycle rules |

