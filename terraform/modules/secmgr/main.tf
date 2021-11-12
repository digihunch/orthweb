resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_+:?"
}

resource "aws_secretsmanager_secret" "secretDB" {
  name = "${var.resource_prefix}DatabaseCreds"
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBSecret" })
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

resource "aws_security_group" "epsecgroup" {
  name        = "${var.resource_prefix}-vpcep_sg"
  description = "security group for vpc endpoint"
  vpc_id      = data.aws_vpc.mainVPC.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.mainVPC.cidr_block]
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-EndPointSecurityGroup" })
}

resource "aws_vpc_endpoint" "secmgr" {
  vpc_id              = data.aws_vpc.mainVPC.id
  service_name        = "com.amazonaws.${data.aws_region.this.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.epsecgroup.id]
  subnet_ids          = [var.public_subnet1_id, var.public_subnet2_id]
  # For each interface endpoint, you can choose one subnet per AZ. 
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-EndPointForSecMgr" })
}
