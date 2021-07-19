data "aws_subnet" "private_subnet1" {
  id = var.private_subnet1_id
}

data "aws_secretsmanager_secret_version" "dbcreds" {
  secret_id = var.db_secret_id
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.dbcreds.secret_string
  )
}
