output "secret_info" {
  value = {
    db_secret_id    = aws_secretsmanager_secret.secretDB.id
    db_secret_arn   = aws_secretsmanager_secret.secretDB.arn
  }
}
output "custom_key_id" {
  value = aws_kms_key.customKey.arn
}
