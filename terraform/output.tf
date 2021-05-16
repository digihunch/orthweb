output "hostinfo" {
  value = "ec2-user@${aws_instance.orthweb.public_dns}"
}
output "dbinfo" {
  value = aws_db_instance.postgres.endpoint
}
