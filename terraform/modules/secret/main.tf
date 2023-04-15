resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!%*-_+:?"
}

resource "aws_kms_key" "customKey" {
  description             = "This key is used to encrypt resources"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.resource_prefix}-KMS-KeyPolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
        }, {
        Sid    = "Allow Cloud Watch, VPC flow log and s3 access logging sources to use the key"
        Effect = "Allow"
        Principal = {
          "Service" : [
            "logs.${data.aws_region.this.name}.amazonaws.com",
            "delivery.logs.amazonaws.com",
            "logging.s3.amazonaws.com"
          ]
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
      }
    ]
  })
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-Custom-KMS-Key" })
}

resource "aws_secretsmanager_secret" "secretDB" {
  name       = "${var.resource_prefix}DatabaseCreds"
  kms_key_id = aws_kms_key.customKey.arn
  tags       = merge(var.resource_tags, { Name = "${var.resource_prefix}-DBSecret" })
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

