data "aws_caller_identity" "current" {
}

data "aws_region" "this" {}

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
  tags = { Name = "${var.resource_prefix}-Custom-KMS-Key" }
}

