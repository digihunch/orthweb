data "aws_subnet" "private_subnet1" {
  id = var.private_subnet1_id
}

data "aws_vpc" "mainVPC" {
  id = data.aws_subnet.private_subnet1.vpc_id
}

data "aws_secretsmanager_secret_version" "dbcreds" {
  secret_id = var.db_secret_id
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.dbcreds.secret_string
  )
  db_log_exports        = ["postgresql", "upgrade"]
  db_log_retention_days = 7
}
