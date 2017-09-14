# tf_log_storage

This module creates an S3 bucket suitable for receiving logs from other AWS services such as S3, CloudFront, and CloudTrails, which generate an enormous amount of log data. It implements a configurable log retention policy, which allows you to efficiently manage logs across different storage classes (E.g. glacier) and ultimately expire the data altogether.


