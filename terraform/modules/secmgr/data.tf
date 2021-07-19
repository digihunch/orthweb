data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

data "aws_secretsmanager_secret" "secretDB" {
  arn = aws_secretsmanager_secret.secretDB.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secretDB.arn
  depends_on = [aws_secretsmanager_secret_version.sversion]
}
