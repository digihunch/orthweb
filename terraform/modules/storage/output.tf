output "s3_info" {
  value = {
    bucket_domain_name = aws_s3_bucket.orthbucket.bucket_domain_name
    bucket_name        = aws_s3_bucket.orthbucket.bucket
    logging_bucket_arn = aws_s3_bucket.logging_bucket.arn
  }
}
