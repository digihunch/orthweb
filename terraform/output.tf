output "hostinfo" {
  value = "ec2-user@${aws_instance.orthweb.public_dns}"
}
output "dbinfo" {
  value = aws_db_instance.postgres.endpoint
}
output "s3bucket" {
  value = aws_s3_bucket.orthbucket.bucket_domain_name
}
