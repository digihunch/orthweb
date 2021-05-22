
resource "aws_db_instance" "postgres" {
  allocated_storage                   = 5
  storage_type                        = "standard" #magnetic drive minimum 5g storage
  engine                              = "postgres"
  engine_version                      = "12.2"
  instance_class                      = "db.t2.micro"
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
}

