resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_+:?"
}

resource "random_id" "randsuffix" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "secretDB" {
  name = "DatabaseCreds${random_id.randsuffix.hex}"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.secretDB.id
  secret_string = <<EOF
   {
    "username": "myuser",
    "password": "${random_password.password.result}"
   }
EOF
  depends_on = [aws_secretsmanager_secret.secretDB]
}

data "aws_secretsmanager_secret" "secretDB" {
  arn = aws_secretsmanager_secret.secretDB.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secretDB.arn
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

