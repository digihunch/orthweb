resource "aws_key_pair" "runner-pubkey" {
  count      = (var.public_key == "") ? 0 : 1
  key_name   = "${var.resource_prefix}-runner-pubkey"
  public_key = var.public_key
}

resource "aws_security_group" "ec2-secgrp" {
  name        = "${var.resource_prefix}-ec2-sg"
  description = "security group for ec2 instance"
  vpc_id      = var.vpc_config.vpc_id
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ping from anywhere"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow outbound access"
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-EC2SecurityGroup" })
}

resource "aws_security_group" "business-traffic-secgrp" {
  name        = "${var.resource_prefix}-business-traffic-sg"
  description = "security group for business traffic"
  vpc_id      = var.vpc_config.vpc_id
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
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-BusinessTrafficSecurityGroup" })
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
        "${var.custom_key_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_network_interface" "primary_nic" {
  subnet_id       = var.vpc_config.public_subnet1_id
  security_groups = [aws_security_group.ec2-secgrp.id, aws_security_group.business-traffic-secgrp.id]
  tags            = merge(var.resource_tags, { Name = "${var.resource_prefix}-Primary-EC2-Business-Interface" })
  depends_on      = [aws_security_group.ec2-secgrp, aws_security_group.business-traffic-secgrp]
}

resource "aws_instance" "orthweb_primary" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.deployment_options.PrimaryInstanceType
  ebs_optimized = true
  user_data     = data.template_cloudinit_config.orthconfig.rendered
  key_name      = (var.public_key == "") ? null : aws_key_pair.runner-pubkey[0].key_name
  monitoring = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted = true
    kms_key_id = var.custom_key_arn
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.primary_nic.id
  }

  iam_instance_profile = aws_iam_instance_profile.inst_profile.name
  tags                 = merge(var.resource_tags, { Name = "${var.resource_prefix}-Primary-EC2-Instance" })
  depends_on = [aws_eip.orthweb_eip]
}

resource "aws_eip" "orthweb_eip" {
  vpc  = true
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-Floating-EIP" })
}

resource "aws_eip_association" "floating_eip_assoc" {
  allocation_id        = aws_eip.orthweb_eip.id
  network_interface_id = aws_network_interface.primary_nic.id
}

## secondary instance
resource "aws_network_interface" "secondary_nic" {
  subnet_id       = var.vpc_config.public_subnet2_id
  security_groups = [aws_security_group.ec2-secgrp.id, aws_security_group.business-traffic-secgrp.id]
  tags            = merge(var.resource_tags, { Name = "${var.resource_prefix}-Secondary-EC2-Business-Interface" })
  depends_on      = [aws_security_group.ec2-secgrp, aws_security_group.business-traffic-secgrp]
}

resource "aws_instance" "orthweb_secondary" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.deployment_options.SecondaryInstanceType
  ebs_optimized = true
  user_data     = data.template_cloudinit_config.orthconfig.rendered
  key_name      = (var.public_key == "") ? null : aws_key_pair.runner-pubkey[0].key_name
  monitoring = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted = true
    kms_key_id = var.custom_key_arn
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.secondary_nic.id
  }
  iam_instance_profile = aws_iam_instance_profile.inst_profile.name
  tags                 = merge(var.resource_tags, { Name = "${var.resource_prefix}-Secondary-EC2-Instance" })
}

