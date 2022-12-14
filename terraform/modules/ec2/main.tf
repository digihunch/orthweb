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

resource "aws_launch_template" "orthweb_launch_template" {
  name          = "${var.resource_prefix}-ec2-launch-template"
  key_name      = (var.public_key == "") ? null : aws_key_pair.runner-pubkey[0].key_name
  instance_type = var.deployment_options.InstanceType
  user_data     = data.template_cloudinit_config.orthconfig.rendered
  image_id      = data.aws_ami.amazon_linux.id
  iam_instance_profile {
    name = aws_iam_instance_profile.inst_profile.name
  }
  # Process in docker needs to get instance metadata to assume the IAM role for EC2 instance. With IMDSv2, we need set http_put_response_hop_limit to 2. Otherwise, process in Docker container will not be able to read/write to S3 bucket using the IAM role attached to the instance profile. Ref: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      encrypted   = true
      kms_key_id  = var.custom_key_arn
    }
  }
}

resource "aws_network_interface" "primary_nic" {
  subnet_id       = var.vpc_config.public_subnet1_id
  security_groups = [aws_security_group.ec2-secgrp.id, aws_security_group.business-traffic-secgrp.id]
  tags            = merge(var.resource_tags, { Name = "${var.resource_prefix}-Primary-EC2-Business-Interface" })
  depends_on      = [aws_security_group.ec2-secgrp, aws_security_group.business-traffic-secgrp]
}

resource "aws_instance" "orthweb_primary" {
  ebs_optimized = true
  monitoring    = true
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.primary_nic.id
  }
  launch_template {
    id      = aws_launch_template.orthweb_launch_template.id
    version = "$Latest"
  }
  tags       = merge(var.resource_tags, { Name = "${var.resource_prefix}-Primary-EC2-Instance" })
  depends_on = [aws_eip.orthweb_eip] # bootstrapping script provisions self-signed certificate using EIP's DNS name 
}

## secondary instance
resource "aws_network_interface" "secondary_nic" {
  subnet_id       = var.vpc_config.public_subnet2_id
  security_groups = [aws_security_group.ec2-secgrp.id, aws_security_group.business-traffic-secgrp.id]
  tags            = merge(var.resource_tags, { Name = "${var.resource_prefix}-Secondary-EC2-Business-Interface" })
  depends_on      = [aws_security_group.ec2-secgrp, aws_security_group.business-traffic-secgrp]
}

resource "aws_instance" "orthweb_secondary" {
  ebs_optimized = true
  monitoring    = true
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.secondary_nic.id
  }
  launch_template {
    id      = aws_launch_template.orthweb_launch_template.id
    version = "$Latest"
  }
  tags       = merge(var.resource_tags, { Name = "${var.resource_prefix}-Secondary-EC2-Instance" })
  depends_on = [aws_eip.orthweb_eip] # bootstrapping script provisions self-signed certificate using EIP's DNS name 
}

resource "aws_eip" "orthweb_eip" {
  vpc  = true
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-Floating-EIP" })
}

resource "aws_eip_association" "floating_eip_assoc" {
  allocation_id        = aws_eip.orthweb_eip.id
  network_interface_id = aws_network_interface.primary_nic.id
}
