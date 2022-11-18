data "aws_subnet" "private_subnet1" {
  id = var.private_subnet1_id
}

data "aws_subnet" "private_subnet2" {
  id = var.private_subnet2_id
}

data "aws_vpc" "mainVPC" {
  id = data.aws_subnet.private_subnet1.vpc_id
}

data "aws_region" "this" {}

data "aws_secretsmanager_secret" "secretDB" {
  arn = aws_secretsmanager_secret.secretDB.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id  = data.aws_secretsmanager_secret.secretDB.arn
  depends_on = [aws_secretsmanager_secret_version.sversion]
}
