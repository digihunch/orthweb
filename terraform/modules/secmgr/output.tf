output "secret_info" {
  value = {
    db_secret_id = aws_secretsmanager_secret.secretDB.id
  }
}
