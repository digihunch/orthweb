resource "aws_key_pair" "runner-pubkey" {
  key_name   = "${var.resource_prefix}-runner-pubkey"
  public_key = var.public_key
}

resource "aws_security_group" "orthsecgrp" {
  name        = "${var.resource_prefix}-orth_sg"
  description = "security group for orthanc"
  vpc_id      = data.aws_subnet.public_subnet.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Orthanc Web Portal"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "DICOM Communication"
    from_port   = 11112
    to_port     = 11112
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-WorkloadSecurityGroup" })
}

resource "aws_iam_instance_profile" "inst_profile" {
  name = "${var.resource_prefix}-inst_profile"
  role = data.aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy" "secret_reader_policy" {
  name = "${var.resource_prefix}-secret_reader_policy"
  role = data.aws_iam_role.instance_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_secretsmanager_secret.secretDB.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "database_access_policy" {
  name   = "${var.resource_prefix}-database_access_policy"
  role   = data.aws_iam_role.instance_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds-db:connect"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_db_instance.postgres.db_instance_arn}"
      ]
    }
  ]
}
EOF
}

# IAM role needs to access KMS key to upload and download objects in S3 bucket with SSE 
# https://aws.amazon.com/premiumsupport/knowledge-center/decrypt-kms-encrypted-objects-s3/
# https://aws.amazon.com/premiumsupport/knowledge-center/s3-access-denied-error-kms/
resource "aws_iam_role_policy" "s3_access_policy" {
  name   = "${var.resource_prefix}-s3_access_policy"
  role   = data.aws_iam_role.instance_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_s3_bucket.orthbucket.arn}",
        "${data.aws_s3_bucket.orthbucket.arn}/*",
        "${var.s3_key_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_instance" "orthweb" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.medium"
  user_data              = data.template_cloudinit_config.orthconfig.rendered
  key_name               = aws_key_pair.runner-pubkey.key_name
  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.inst_profile.name
  tags                   = merge(var.resource_tags, { Name = "${var.resource_prefix}-EC2-Instance" })
}

