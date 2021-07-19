output "s3_info" {
  value = {
    bucket_domain_name = aws_s3_bucket.orthbucket.bucket_domain_name
    bucket_name = aws_s3_bucket.orthbucket.bucket
    key_arn = aws_kms_key.s3key.arn
  }
}
