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
  depends_on = [aws_secretsmanager_secret_version.sversion]
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_vpc_endpoint" "secmgr" {
  vpc_id              = aws_vpc.orthmain.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.epsecgroup.id]
  subnet_ids          = [aws_subnet.publicsubnet.id]
  # For each interface endpoint, you can choose one subnet per AZ. 
}
