
data "aws_caller_identity" "current" {
  # no arguments
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!%*-_+:?"
}

resource "aws_secretsmanager_secret" "secretDB" {
  name       = "${var.resource_prefix}DatabaseCreds"
  kms_key_id = var.custom_key_arn
  tags       = { Name = "${var.resource_prefix}-DBSecret" }
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.secretDB.id
  secret_string = <<EOF
   {
    "username": "myuser",
    "password": "${random_password.password.result}"
   }
EOF
  depends_on    = [aws_secretsmanager_secret.secretDB]
}

data "aws_secretsmanager_secret_version" "dbcreds" {
  secret_id  = aws_secretsmanager_secret.secretDB.arn
  depends_on = [aws_secretsmanager_secret_version.sversion]
}

#resource "aws_secretsmanager_secret_policy" "secretmgrSecretPolicy" {
#  secret_arn = aws_secretsmanager_secret.secretDB.arn
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Id      = "${var.resource_prefix}-OrthSecretPolicy"
#    Statement = [
#      {
#        Sid       = "RestrictGetSecretValueoperation"
#        Effect    = "Allow"
#        Principal = {
#          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.role_name}"
#        }
#        Action    = "secretsmanager:GetSecretValue"
#        Resource = [
#          aws_secretsmanager_secret.secretDB.arn
#        ]
#      }
#    ]
#  })
#}

data "aws_subnet" "private_subnet1" {
  id = var.private_subnet1_id
}

data "aws_vpc" "mainVPC" {
  id = data.aws_subnet.private_subnet1.vpc_id
}

locals {
  db_log_exports        = ["postgresql", "upgrade"]
  db_log_retention_days = 7
}

resource "aws_db_subnet_group" "dbsubnetgroup" {
  name       = "${var.resource_prefix}-dbsubnetgroup"
  subnet_ids = [var.private_subnet1_id, var.private_subnet2_id]
  tags       = { Name = "${var.resource_prefix}-DBSubnetGroup" }
}

resource "aws_security_group" "dbsecgroup" {
  name        = "${var.resource_prefix}-orthdb-secgrp"
  description = "postgres security group"
  vpc_id      = data.aws_vpc.mainVPC.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.mainVPC.cidr_block]
    description = "allow access to db port from VPC"
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [data.aws_vpc.mainVPC.cidr_block]
    description = "allow ping from VPC"
  }
  tags = { Name = "${var.resource_prefix}-DBSecurityGroup" }
}

resource "aws_db_parameter_group" "dbparamgroup" {
  name   = "${var.resource_prefix}-orthdb-paramgrp"
  family = var.psql_engine_family 

  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
  tags = { Name = "${var.resource_prefix}-DBParameterGroup" }
}

resource "aws_iam_role" "rds_monitoring_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "MonitoringRoleForRDS"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  tags                = { Name = "${var.resource_prefix}-DB-Monitoring-IAM-role" }
}

resource "aws_cloudwatch_log_group" "db_log_group" {
  #checkov:skip=CKV_AWS_338: retention of 1 year is not a reqruirement
  for_each          = toset([for log in local.db_log_exports : log])
  name              = "/aws/rds/instance/${var.resource_prefix}-orthancpostgres/${each.value}"
  kms_key_id        = var.custom_key_arn
  retention_in_days = local.db_log_retention_days
  tags              = { Name = "${var.resource_prefix}-DBInstance-${each.value}" }
}

resource "aws_db_instance" "postgres" {
  #checkov:skip=CKV_AWS_354: performance insight is not a requirement
  #checkov:skip=CKV_AWS_293: deletion protection is not a requirement
  #checkov:skip=CKV_AWS_353: performance insight is not a requirement
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring_role.arn
  storage_type                        = var.db_instance_storage_type
  allocated_storage                   = var.db_instance_allocated_storage
  engine                              = "postgres"
  engine_version                      = var.psql_engine_version
  instance_class                      = var.db_instance_class 
  identifier                          = "${var.resource_prefix}-orthancpostgres"
  db_name                             = "orthancdb"
  username                            = jsondecode(data.aws_secretsmanager_secret_version.dbcreds.secret_string).username
  password                            = jsondecode(data.aws_secretsmanager_secret_version.dbcreds.secret_string).password
  port                                = "5432"
  deletion_protection                 = false
  skip_final_snapshot                 = "true"
  iam_database_authentication_enabled = true
  final_snapshot_identifier           = "demodb"
  vpc_security_group_ids              = [aws_security_group.dbsecgroup.id]
  db_subnet_group_name                = aws_db_subnet_group.dbsubnetgroup.name
  parameter_group_name                = aws_db_parameter_group.dbparamgroup.name
  storage_encrypted                   = true
  multi_az                            = true
  auto_minor_version_upgrade          = true
  enabled_cloudwatch_logs_exports     = local.db_log_exports
  kms_key_id                          = var.custom_key_arn
  depends_on                          = [aws_cloudwatch_log_group.db_log_group]
  tags                                = { Name = "${var.resource_prefix}-DBInstance" }
}

