output "db_info" {
  value = {
    db_endpoint    = aws_db_instance.postgres.endpoint
    db_instance_id = aws_db_instance.postgres.id
  }
}

output "secret_info" {
  value = {
    db_secret_id  = aws_secretsmanager_secret.secretDB.id
    db_secret_arn = aws_secretsmanager_secret.secretDB.arn
  }
}
