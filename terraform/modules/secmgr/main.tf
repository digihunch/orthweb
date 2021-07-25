resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_+:?"
}

resource "aws_secretsmanager_secret" "secretDB" {
  name = "DatabaseCreds${var.name_suffix}"
  tags = {
    Name = "Secret-${var.tag_suffix}"
  }
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

resource "aws_security_group" "epsecgroup" {
  name        = "vpcep_sg"
  description = "security group for vpc endpoint"
  vpc_id      = data.aws_subnet.public_subnet1.vpc_id 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "EndPointSecurityGroup-${var.tag_suffix}"
  }
}

resource "aws_vpc_endpoint" "secmgr" {
  vpc_id              = data.aws_subnet.public_subnet1.vpc_id 
  service_name        = "com.amazonaws.${data.aws_region.this.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.epsecgroup.id]
  subnet_ids          = [var.public_subnet1_id, var.public_subnet2_id]
  # For each interface endpoint, you can choose one subnet per AZ. 
  tags = {
    Name = "EndPointForSecMgr-${var.tag_suffix}"
  }
}
