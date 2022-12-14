resource "aws_db_subnet_group" "dbsubnetgroup" {
  name       = "${var.resource_prefix}-dbsubnetgroup"
  subnet_ids = [var.private_subnet1_id, var.private_subnet2_id]
  tags       = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBSubnetGroup" })
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
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBSecurityGroup" })
}

resource "aws_db_parameter_group" "dbparamgroup" {
  name   = "${var.resource_prefix}-orthdb-paramgrp"
  family = "postgres14"

  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBParameterGroup" })
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
  tags                = merge(var.resource_tags, { Name = "${var.resource_prefix}-DB-Monitoring-IAM-role" })
}

resource "aws_cloudwatch_log_group" "db_log_group" {
  for_each          = toset([for log in local.db_log_exports : log])
  name              = "/aws/rds/instance/${var.resource_prefix}-orthancpostgres/${each.value}"
  kms_key_id        = var.custom_key_arn
  retention_in_days = local.db_log_retention_days
  tags              = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBInstance-${each.value}" })
}

resource "aws_db_instance" "postgres" {
  allocated_storage                   = 5
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring_role.arn
  storage_type                        = "standard" #magnetic drive minimum 5g storage
  engine                              = "postgres"
  engine_version                      = "14.2"
  instance_class                      = "db.t3.small" # t2.micro does not support encryption at rest
  identifier                          = "${var.resource_prefix}-orthancpostgres"
  db_name                             = "orthancdb"
  username                            = local.db_creds.username
  password                            = local.db_creds.password
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
  tags                                = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBInstance" })
}

