output "secret_info" {
  value = {
    db_secret_id    = aws_secretsmanager_secret.secretDB.id
    db_secret_arn   = aws_secretsmanager_secret.secretDB.arn
    ep_service_name = aws_vpc_endpoint.secmgr.service_name
  }
}
