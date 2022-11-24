resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!%*-_+:?"
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

resource "aws_secretsmanager_secret_policy" "secretmgrSecretPolicy" {
  secret_arn = aws_secretsmanager_secret.secretDB.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.resource_prefix}-OrthSecretPolicy"
    Statement = [
      {
        Sid       = "RestrictGetSecretValueoperation"
        Effect    = "Deny"
        Principal = "*"
        Action    = "secretsmanager:GetSecretValue"
        Resource = [
          aws_secretsmanager_secret.secretDB.arn
        ]
        Condition = {
          StringNotLike = {
            "aws:userId" = [
              "${data.aws_iam_role.instance_role.unique_id}:*", # instance role
              "${data.aws_caller_identity.current.account_id}", # root user
              "${data.aws_caller_identity.current.user_id}"     # deployment user
            ]
          }
        }
      }
    ]
  })
}


resource "aws_security_group" "secmgrepsecgroup" {
  name        = "${var.resource_prefix}-secmgr_vpcep_sg"
  description = "security group for secret manager vpc endpoint"
  vpc_id      = data.aws_vpc.mainVPC.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.mainVPC.cidr_block]
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-SecretManagerEndPointSecurityGroup" })
}

resource "aws_vpc_endpoint" "secmgr" {
  vpc_id              = data.aws_vpc.mainVPC.id
  service_name        = "com.amazonaws.${data.aws_region.this.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.secmgrepsecgroup.id]
  subnet_ids          = [var.private_subnet1_id, var.private_subnet2_id]
  # For each interface endpoint, you can choose one subnet per AZ. 
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-EndPointForSecMgr" })
}
