resource "aws_kms_key" "dbkey" {
  description             = "This key is used to encrypt database storage"
  deletion_window_in_days = 10
  tags = {
    Name = "DB-KMS-Key-${var.tag_suffix}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "dbsubnetgroup"
  subnet_ids = [var.private_subnet1_id, var.private_subnet2_id]
}

resource "aws_security_group" "dbsecgroup" {
  name        = "orthdb_sg"
  description = "postgres security group"
  vpc_id      = data.aws_subnet.private_subnet1.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DBSecurityGroup-${var.tag_suffix}"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage                   = 5
  storage_type                        = "standard" #magnetic drive minimum 5g storage
  engine                              = "postgres"
  engine_version                      = "12.2"
  instance_class                      = "db.t2.small" # t2.micro does not support encryption at rest
  identifier                          = "orthancpostgres"
  name                                = "orthancdb"
  username                            = local.db_creds.username
  password                            = local.db_creds.password
  port                                = "5432"
  deletion_protection                 = false
  skip_final_snapshot                 = "true"
  iam_database_authentication_enabled = true
  final_snapshot_identifier           = "demodb"
  vpc_security_group_ids              = ["${aws_security_group.dbsecgroup.id}"]
  db_subnet_group_name                = aws_db_subnet_group.default.name
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.dbkey.arn
}

