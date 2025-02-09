output "db_info" {
  value = {
    db_address             = aws_db_instance.postgres.address
    db_port                = aws_db_instance.postgres.port
    db_instance_identifier = aws_db_instance.postgres.identifier
    db_instance_arn        = aws_db_instance.postgres.arn
  }
}

output "secret_info" {
  value = {
    db_secret_arn  = aws_secretsmanager_secret.secretDB.arn
    db_secret_name = aws_secretsmanager_secret.secretDB.name
  }
}
