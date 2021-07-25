resource "aws_key_pair" "runner-pubkey" {
  key_name   = "runner-pubkey"
  public_key = var.public_key 
}

resource "aws_security_group" "orthsecgrp" {
  name        = "orth_sg"
  description = "security group for orthanc"
  vpc_id      = data.aws_subnet.public_subnet1.vpc_id

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
    description = "Orthanc Web"
    from_port   = 8042
    to_port     = 8042
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "DICOM Image"
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
  tags = {
    Name = "WorkloadSecurityGroup-${var.tag_suffix}"
  }
}

resource "aws_iam_instance_profile" "inst_profile" {
  name = "inst_profile"
  role = data.aws_iam_role.instance_role.name
}

resource "aws_iam_role_policy" "secret_reader_policy" {
  name = "secret_reader_policy"
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
  name   = "database_access_policy"
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
  name   = "s3_access_policy"
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

resource "aws_instance" "orthweb_1" {
  ami                    = var.amilut[data.aws_region.this.name]
  instance_type          = "t3.micro"
  user_data              = data.template_cloudinit_config.orthconfig.rendered
  key_name               = aws_key_pair.runner-pubkey.key_name 
  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
  subnet_id              = var.public_subnet1_id
  iam_instance_profile   = aws_iam_instance_profile.inst_profile.name
  tags = {
    Name = "Orthweb1-${var.tag_suffix}"
  }
}

resource "aws_instance" "orthweb_2" {
  ami                    = var.amilut[data.aws_region.this.name]
  instance_type          = "t3.micro"
  user_data              = data.template_cloudinit_config.orthconfig.rendered
  key_name               = aws_key_pair.runner-pubkey.key_name 
  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
  subnet_id              = var.public_subnet2_id
  iam_instance_profile   = aws_iam_instance_profile.inst_profile.name
  tags = {
    Name = "Orthweb2-${var.tag_suffix}"
  }
}
#resource "aws_launch_template" "orthweb_inst_tpl" {
#  image_id = var.amilut[data.aws_region.this.name]
#  instance_type = "t3.micro"
#  user_data = data.template_cloudinit_config.orthconfig.rendered
#  key_name = aws_key_pair.runner-pubkey.key_name
#  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
#  iam_instance_profile {
#    name = aws_iam_instance_profile.inst_profile.name
#  }
#}
#
#resource "aws_instance" "orthweb_1" {
#  launch_template {
#    id = aws_launch_template.orthweb_inst_tpl.id
#    version = "$Latest" 
#  }
#  subnet_id = var.public_subnet1_id 
#  tags = {
#    Name = "Orthweb-Instance1-${var.tag_suffix}"
#  }
#}
#
#resource "aws_instance" "orthweb_2" {
#  launch_template {
#    id = aws_launch_template.orthweb_inst_tpl.id
#    version = "$Latest" 
#  }
#  subnet_id = var.public_subnet2_id 
#  tags = {
#    Name = "Orthweb-Instance2-${var.tag_suffix}"
#  }
#}
#
#
