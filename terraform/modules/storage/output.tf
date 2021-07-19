output "s3_info" {
  value = {
    bucket_name = aws_s3_bucket.orthbucket.bucket_domain_name
  }
}
