

<!-- markdownlint-disable -->
# terraform-aws-s3-log-storage <a href="https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content="><img align="right" src="https://cloudposse.com/logo-300x69.svg" width="150" /></a>
<a href="https://github.com/cloudposse/terraform-aws-s3-log-storage/releases/latest"><img src="https://img.shields.io/github/release/cloudposse/terraform-aws-s3-log-storage.svg" alt="Latest Release"/></a><a href="https://slack.cloudposse.com"><img src="https://slack.cloudposse.com/badge.svg" alt="Slack Community"/></a>
<!-- markdownlint-restore -->

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `cloudposse/build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

This module creates an S3 bucket suitable for receiving logs from other `AWS` services such as `S3`, `CloudFront`, and `CloudTrails`.

This module implements a configurable log retention policy, which allows you to efficiently manage logs across different storage classes (_e.g._ `Glacier`) and ultimately expire the data altogether.

It enables [default server-side encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-encryption.html).

It [blocks public access to the bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) by default.

As of March, 2022, this module is primarily a wrapper around our 
[s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)
module, with some options preconfigured and SQS notifications added. If it does not exactly suit your needs,
you may want to use the `s3-bucket` module directly.

As of version 1.0 of this module, most of the inputs are marked `nullable = false`, 
meaning you can pass in `null` and get the default value rather than having the 
input be actually set to `null`. This is technically a breaking change from previous versions,
but since `null` was not a valid value for most of these variables, we are not considering it
a truly breaking change. However, be mindful that the behavior of inputs set to `null`
may change in the future, so we recommend setting them to the desired value explicitly.


> [!TIP]
> #### 👽 Use Atmos with Terraform
> Cloud Posse uses [`atmos`](https://atmos.tools) to easily orchestrate multiple environments using Terraform. <br/>
> Works with [Github Actions](https://atmos.tools/integrations/github-actions/), [Atlantis](https://atmos.tools/integrations/atlantis), or [Spacelift](https://atmos.tools/integrations/spacelift).
>
> <details>
> <summary><strong>Watch demo of using Atmos with Terraform</strong></summary>
> <img src="https://github.com/cloudposse/atmos/blob/master/docs/demo.gif?raw=true"/><br/>
> <i>Example of running <a href="https://atmos.tools"><code>atmos</code></a> to manage infrastructure from our <a href="https://atmos.tools/quick-start/">Quick Start</a> tutorial.</i>
> </detalis>





## Usage


This module supports full S3 [storage lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)
configuration via our [s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket) module:

```hcl
locals {
  lifecycle_configuration_rule = {
    enabled = true # bool
    id      = "v2rule"

    abort_incomplete_multipart_upload_days = 1 # number

    filter_and = null
    expiration = {
      days = 120 # integer > 0
    }
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 3  # integer > 0
      noncurrent_days           = 60 # integer >= 0
    }
    transition = [{
      days          = 30            # integer >= 0
      storage_class = "STANDARD_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
      },
      {
        days          = 60           # integer >= 0
        storage_class = "ONEZONE_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
    noncurrent_version_transition = [{
      newer_noncurrent_versions = 3            # integer >= 0
      noncurrent_days           = 30           # integer >= 0
      storage_class             = "ONEZONE_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
  }
}

module "log_storage" {
  source = "cloudposse/s3-log-storage/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  name      = "logs"
  stage     = "test"
  namespace = "eg"
  
  versioning_enabled            = true
  lifecycle_configuration_rules = [var.lifecycle_configuration_rule]
}

```

> [!IMPORTANT]
> In Cloud Posse's examples, we avoid pinning modules to specific versions to prevent discrepancies between the documentation
> and the latest released versions. However, for your own projects, we strongly advise pinning each module to the exact version
> you're using. This practice ensures the stability of your infrastructure. Additionally, we recommend implementing a systematic
> approach for updating versions to avoid unexpected changes.








<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_s3_bucket"></a> [aws\_s3\_bucket](#module\_aws\_s3\_bucket) | cloudposse/s3-bucket/aws | 3.1.3 |
| <a name="module_bucket_name"></a> [bucket\_name](#module\_bucket\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_sqs_queue.notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_incomplete_multipart_upload_days"></a> [abort\_incomplete\_multipart\_upload\_days](#input\_abort\_incomplete\_multipart\_upload\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Maximum time (in days) that you want to allow multipart uploads to remain in progress | `number` | `null` | no |
| <a name="input_access_log_bucket_name"></a> [access\_log\_bucket\_name](#input\_access\_log\_bucket\_name) | Name of the S3 bucket where S3 access logs will be sent to | `string` | `""` | no |
| <a name="input_access_log_bucket_prefix"></a> [access\_log\_bucket\_prefix](#input\_access\_log\_bucket\_prefix) | Prefix to prepend to the current S3 bucket name, where S3 access logs will be sent to | `string` | `"logs/"` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.<br>Deprecated by AWS in favor of bucket policies.<br>Automatically disabled if `s3_object_ownership` is set to "BucketOwnerEnforced".<br>Defaults to "private" for backwards compatibility, but we recommend setting `s3_object_ownership` to "BucketOwnerEnforced" instead. | `string` | `"log-delivery-write"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allow_encrypted_uploads_only"></a> [allow\_encrypted\_uploads\_only](#input\_allow\_encrypted\_uploads\_only) | Set to `true` to prevent uploads of unencrypted objects to S3 bucket | `bool` | `false` | no |
| <a name="input_allow_ssl_requests_only"></a> [allow\_ssl\_requests\_only](#input\_allow\_ssl\_requests\_only) | Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Set to `false` to disable the blocking of new public access lists on the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Set to `false` to disable the blocking of new public policies on the bucket | `bool` | `true` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Set this to true to use Amazon S3 Bucket Keys for SSE-KMS, which reduce the cost of AWS KMS requests.<br><br>For more information, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name. If provided, the bucket will be created with this name<br>instead of generating the name from the context. | `string` | `""` | no |
| <a name="input_bucket_notifications_enabled"></a> [bucket\_notifications\_enabled](#input\_bucket\_notifications\_enabled) | Send notifications for the object created events. Used for 3rd-party log collection from a bucket | `bool` | `false` | no |
| <a name="input_bucket_notifications_prefix"></a> [bucket\_notifications\_prefix](#input\_bucket\_notifications\_prefix) | Prefix filter. Used to manage object notifications | `string` | `""` | no |
| <a name="input_bucket_notifications_type"></a> [bucket\_notifications\_type](#input\_bucket\_notifications\_type) | Type of the notification configuration. Only SQS is supported. | `string` | `"SQS"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enable_glacier_transition"></a> [enable\_glacier\_transition](#input\_enable\_glacier\_transition) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Enables the transition to AWS Glacier which can cause unnecessary costs for huge amount of small files | `bool` | `null` | no |
| <a name="input_enable_noncurrent_version_expiration"></a> [enable\_noncurrent\_version\_expiration](#input\_enable\_noncurrent\_version\_expiration) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Enable expiration of non-current versions | `bool` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Number of days after which to expunge the objects | `number` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | When `true`, permits a non-empty S3 bucket to be deleted by first deleting all objects in the bucket.<br>THESE OBJECTS ARE NOT RECOVERABLE even if they were versioned and stored in Glacier.<br>Must be set `false` unless `force_destroy_enabled` is also `true`. | `bool` | `false` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Number of days after which to move the data to the Glacier Flexible Retrieval storage tier | `number` | `null` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | A list of policy grants for the bucket, taking a list of permissions.<br>Conflicts with `acl`. Set `acl` to `null` to use this.<br>Deprecated by AWS in favor of bucket policies, but still required for some log delivery services.<br>Automatically disabled if `s3_object_ownership` is set to "BucketOwnerEnforced". | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `[]` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Set to `false` to disable the ignoring of public access lists on the bucket | `bool` | `true` | no |
| <a name="input_kms_master_key_arn"></a> [kms\_master\_key\_arn](#input\_kms\_master\_key\_arn) | The AWS KMS master key ARN used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lifecycle_configuration_rules"></a> [lifecycle\_configuration\_rules](#input\_lifecycle\_configuration\_rules) | A list of S3 bucket v2 lifecycle rules, as specified in [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)"<br>These rules are not affected by the deprecated `lifecycle_rule_enabled` flag.<br>**NOTE:** Unless you also set `lifecycle_rule_enabled = false` you will also get the default deprecated rules set on your bucket. | <pre>list(object({<br>    enabled = bool<br>    id      = string<br><br>    abort_incomplete_multipart_upload_days = number<br><br>    # `filter_and` is the `and` configuration block inside the `filter` configuration.<br>    # This is the only place you should specify a prefix.<br>    filter_and = optional(object({<br>      object_size_greater_than = optional(number) # integer >= 0<br>      object_size_less_than    = optional(number) # integer >= 1<br>      prefix                   = optional(string)<br>      tags                     = optional(map(string))<br>    }))<br>    expiration = optional(object({<br>      date                         = optional(string) # string, RFC3339 time format, GMT<br>      days                         = optional(number) # integer > 0<br>      expired_object_delete_marker = optional(bool)<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      newer_noncurrent_versions = optional(number) # integer > 0<br>      noncurrent_days           = optional(number) # integer >= 0<br>    }))<br>    transition = optional(list(object({<br>      date          = optional(string) # string, RFC3339 time format, GMT<br>      days          = optional(number) # integer >= 0<br>      storage_class = string           # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.<br>    })), [])<br>    noncurrent_version_transition = optional(list(object({<br>      newer_noncurrent_versions = optional(number) # integer >= 0<br>      noncurrent_days           = optional(number) # integer >= 0<br>      storage_class             = string           # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_lifecycle_prefix"></a> [lifecycle\_prefix](#input\_lifecycle\_prefix) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Prefix filter. Used to manage object lifecycle events | `string` | `null` | no |
| <a name="input_lifecycle_rule_enabled"></a> [lifecycle\_rule\_enabled](#input\_lifecycle\_rule\_enabled) | DEPRECATED: Use `lifecycle_configuration_rules` instead.<br>When `true`, configures lifecycle events on this bucket using individual (now deprecated) variables.<br>When `false`, lifecycle events are not configured using individual (now deprecated) variables, but `lifecycle_configuration_rules` still apply.<br>When `null`, lifecycle events are configured using individual (now deprecated) variables only if `lifecycle_configuration_rules` is empty. | `bool` | `null` | no |
| <a name="input_lifecycle_tags"></a> [lifecycle\_tags](#input\_lifecycle\_tags) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Tags filter. Used to manage object lifecycle events | `map(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_noncurrent\_version\_expiration\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Specifies when non-current object versions expire (in days) | `number` | `null` | no |
| <a name="input_noncurrent_version_transition_days"></a> [noncurrent\_version\_transition\_days](#input\_noncurrent\_version\_transition\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Specifies (in days) when noncurrent object versions transition to Glacier Flexible Retrieval | `number` | `null` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely. | <pre>object({<br>    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.<br>    days  = number<br>    years = number<br>  })</pre> | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Deprecated, use `source_policy_documents` instead): A valid bucket policy JSON document. | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Set to `false` to disable the restricting of making the bucket public | `bool` | `true` | no |
| <a name="input_s3_object_ownership"></a> [s3\_object\_ownership](#input\_s3\_object\_ownership) | Specifies the S3 object ownership control. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'. | `string` | `"BucketOwnerPreferred"` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document.<br>Statements defined in source\_policy\_documents must have unique SIDs.<br>Statement having SIDs that match policy SIDs generated by this module will override them. | `list(string)` | `[]` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"AES256"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_standard_transition_days"></a> [standard\_transition\_days](#input\_standard\_transition\_days) | (Deprecated, use `lifecycle_configuration_rules` instead)<br>Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable object versioning, keeping multiple variants of an object in the same bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Bucket ARN |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | FQDN of bucket |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket Name (aka ID) |
| <a name="output_bucket_notifications_sqs_queue_arn"></a> [bucket\_notifications\_sqs\_queue\_arn](#output\_bucket\_notifications\_sqs\_queue\_arn) | Notifications SQS queue ARN |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Is module enabled |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | Prefix configured for lifecycle rules |
<!-- markdownlint-restore -->


## Related Projects

Check out these related projects.

- [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket) - Terraform module that creates an S3 bucket with an optional IAM user for external CI/CD systems
- [terraform-aws-cloudfront-s3-cdn](https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn) - Terraform module to easily provision CloudFront CDN backed by an S3 origin
- [terraform-aws-s3-website](https://github.com/cloudposse/terraform-aws-s3-website) - Terraform Module for Creating S3 backed Websites and Route53 DNS
- [terraform-aws-user-data-s3-backend](https://github.com/cloudposse/terraform-aws-user-data-s3-backend) - Terraform Module to Offload User Data to S3
- [terraform-aws-s3-logs-athena-query](https://github.com/cloudposse/terraform-aws-s3-logs-athena-query) - A Terraform module that creates an Athena Database and Structure for querying S3 access logs
- [terraform-aws-lb-s3-bucket](https://github.com/cloudposse/terraform-aws-lb-s3-bucket) - Terraform module to provision an S3 bucket with built in IAM policy to allow AWS Load Balancers to ship access logs


> [!TIP]
> #### Use Terraform Reference Architectures for AWS
>
> Use Cloud Posse's ready-to-go [terraform architecture blueprints](https://cloudposse.com/reference-architecture/) for AWS to get up and running quickly.
>
> ✅ We build it with you.<br/>
> ✅ You own everything.<br/>
> ✅ Your team wins.<br/>
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
> <details><summary>📚 <strong>Learn More</strong></summary>
>
> <br/>
>
> Cloud Posse is the leading [**DevOps Accelerator**](https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=commercial_support) for funded startups and enterprises.
>
> *Your team can operate like a pro today.*
>
> Ensure that your team succeeds by using Cloud Posse's proven process and turnkey blueprints. Plus, we stick around until you succeed.
> #### Day-0:  Your Foundation for Success
> - **Reference Architecture.** You'll get everything you need from the ground up built using 100% infrastructure as code.
> - **Deployment Strategy.** Adopt a proven deployment strategy with GitHub Actions, enabling automated, repeatable, and reliable software releases.
> - **Site Reliability Engineering.** Gain total visibility into your applications and services with Datadog, ensuring high availability and performance.
> - **Security Baseline.** Establish a secure environment from the start, with built-in governance, accountability, and comprehensive audit logs, safeguarding your operations.
> - **GitOps.** Empower your team to manage infrastructure changes confidently and efficiently through Pull Requests, leveraging the full power of GitHub Actions.
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
>
> #### Day-2: Your Operational Mastery
> - **Training.** Equip your team with the knowledge and skills to confidently manage the infrastructure, ensuring long-term success and self-sufficiency.
> - **Support.** Benefit from a seamless communication over Slack with our experts, ensuring you have the support you need, whenever you need it.
> - **Troubleshooting.** Access expert assistance to quickly resolve any operational challenges, minimizing downtime and maintaining business continuity.
> - **Code Reviews.** Enhance your team’s code quality with our expert feedback, fostering continuous improvement and collaboration.
> - **Bug Fixes.** Rely on our team to troubleshoot and resolve any issues, ensuring your systems run smoothly.
> - **Migration Assistance.** Accelerate your migration process with our dedicated support, minimizing disruption and speeding up time-to-value.
> - **Customer Workshops.** Engage with our team in weekly workshops, gaining insights and strategies to continuously improve and innovate.
>
> <a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=commercial_support"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
> </details>

## ✨ Contributing

This project is under active development, and we encourage contributions from our community.



Many thanks to our outstanding contributors:

<a href="https://github.com/cloudposse/terraform-aws-s3-log-storage/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudposse/terraform-aws-s3-log-storage&max=24" />
</a>

For 🐛 bug reports & feature requests, please use the [issue tracker](https://github.com/cloudposse/terraform-aws-s3-log-storage/issues).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.
 1. Review our [Code of Conduct](https://github.com/cloudposse/terraform-aws-s3-log-storage/?tab=coc-ov-file#code-of-conduct) and [Contributor Guidelines](https://github.com/cloudposse/.github/blob/main/CONTRIBUTING.md).
 2. **Fork** the repo on GitHub
 3. **Clone** the project to your own machine
 4. **Commit** changes to your own branch
 5. **Push** your work back up to your fork
 6. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

### 🌎 Slack Community

Join our [Open Source Community](https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=slack) on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

### 📰 Newsletter

Sign up for [our newsletter](https://cpco.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=newsletter) and join 3,000+ DevOps engineers, CTOs, and founders who get insider access to the latest DevOps trends, so you can always stay in the know.
Dropped straight into your Inbox every week — and usually a 5-minute read.

### 📆 Office Hours <a href="https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=office_hours"><img src="https://img.cloudposse.com/fit-in/200x200/https://cloudposse.com/wp-content/uploads/2019/08/Powered-by-Zoom.png" align="right" /></a>

[Join us every Wednesday via Zoom](https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=office_hours) for your weekly dose of insider DevOps trends, AWS news and Terraform insights, all sourced from our SweetOps community, plus a _live Q&A_ that you can’t find anywhere else.
It's **FREE** for everyone!
## License

<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge" alt="License"></a>

<details>
<summary>Preamble to the Apache License, Version 2.0</summary>
<br/>
<br/>

Complete license is available in the [`LICENSE`](LICENSE) file.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
</details>

## Trademarks

All other trademarks referenced herein are the property of their respective owners.


---
Copyright © 2017-2024 [Cloud Posse, LLC](https://cpco.io/copyright)


<a href="https://cloudposse.com/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-s3-log-storage&utm_content=readme_footer_link"><img alt="README footer" src="https://cloudposse.com/readme/footer/img"/></a>

<img alt="Beacon" width="0" src="https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-s3-log-storage?pixel&cs=github&cm=readme&an=terraform-aws-s3-log-storage"/>
