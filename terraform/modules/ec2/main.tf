locals {
  instance_sg_configs = {
    mgmtsg = {
      name        = "${var.resource_prefix}-mgmt-sg"
      description = "Security Group for management traffic"
      ingress_rules = [
        {
          from_port   = 8
          to_port     = 0
          protocol    = "icmp"
          cidr_blocks = ["0.0.0.0/0"]
          rule_desc   = "Allow ping from anywhere"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          rule_desc   = "Allow outbound access"
        }
      ]
    },
    appsg = {
      name        = "${var.resource_prefix}-app-sg"
      description = "Security Group for application traffic"
      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          rule_desc   = "Allow web traffic"
        },
        {
          from_port   = 11112
          to_port     = 11112
          protocol    = "tcp"
          cidr_blocks = [var.vpc_config.scu_cidr_block]
          rule_desc   = "Allow DICOM traffic"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          rule_desc   = "Allow outbound access"
        }
      ]
    }
  }
}


data "aws_region" "this" {}

data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_db_instance" "postgres" {
  db_instance_identifier = var.db_instance_id
}

data "aws_s3_bucket" "orthbucket" {
  bucket = var.s3_bucket_name
}

data "aws_secretsmanager_secret" "secretDB" {
  arn = var.db_secret_arn
}

data "cloudinit_config" "orthconfig" {
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata1.sh")
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/userdata2.tpl", {
      db_address       = data.aws_db_instance.postgres.address,
      db_port          = data.aws_db_instance.postgres.port,
      aws_region       = data.aws_region.this.name,
      sec_name         = data.aws_secretsmanager_secret.secretDB.name,
      s3_bucket        = data.aws_s3_bucket.orthbucket.bucket,
      orthanc_image    = var.deployment_options.OrthancImg,
      envoy_image      = var.deployment_options.EnvoyImg,
      floating_eip_dns = aws_eip.orthweb_eip.public_dns
    })
  }
}

resource "aws_key_pair" "runner-pubkey" {
  count      = (var.public_key == "") ? 0 : 1
  key_name   = "${var.resource_prefix}-runner-pubkey"
  public_key = var.public_key
}

resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.resource_prefix}-iamrole-for-ec2-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = { Name = "${var.role_name}" }
}

# EC2 instance needs to connect to AWS Systems Manager 
resource "aws_iam_role_policy_attachment" "ec2_iam_role_ssm_policy_attach" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 instance needs to read DB secret
resource "aws_iam_role_policy" "secret_reader_policy" {
  name = "${var.resource_prefix}-secret_reader_policy"
  role = aws_iam_role.ec2_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret.secretDB.id
      }
    ]
  })
}

# EC2 instance needs to access database
resource "aws_iam_role_policy" "database_access_policy" {
  name = "${var.resource_prefix}-database_access_policy"
  role = aws_iam_role.ec2_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["rds-db:connect"]
        Effect   = "Allow"
        Resource = data.aws_db_instance.postgres.db_instance_arn
      }
    ]
  })
}

# EC2 instance needs to access s3 storage bucket
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.resource_prefix}-s3_access_policy"
  role = aws_iam_role.ec2_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = [
          data.aws_s3_bucket.orthbucket.arn,
          "${data.aws_s3_bucket.orthbucket.arn}/*"
        ]
      }
    ]
  })
}

# EC2 instance to access KMS key to encrypt/decrypt data from encrypted resource it has access to (e.g. database, secret, S3 bucket, EBS)
# https://aws.amazon.com/premiumsupport/knowledge-center/decrypt-kms-encrypted-objects-s3/
# https://aws.amazon.com/premiumsupport/knowledge-center/s3-access-denied-error-kms/
resource "aws_iam_role_policy" "key_access_policy" {
  name = "${var.resource_prefix}-key_access_policy"
  role = aws_iam_role.ec2_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = var.custom_key_arn
      }
    ]
  })
}

resource "aws_security_group" "ec2_sgs" {
  for_each    = local.instance_sg_configs
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_config.vpc_id
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.rule_desc
    }
  }
  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.rule_desc
    }
  }
  tags = { Name = "${var.resource_prefix}-${each.value.name}" }
}

resource "aws_iam_instance_profile" "inst_profile" {
  name = "${var.resource_prefix}-inst_profile"
  role = aws_iam_role.ec2_iam_role.name
}


resource "aws_launch_template" "orthweb_launch_template" {
  #checkov:skip=CKV_AWS_341: Process in docker needs to get instance metadata to assume the IAM role for EC2 instance. With IMDSv2, we need set http_put_response_hop_limit to 2. Otherwise, process in Docker container will not be able to read/write to S3 bucket using the IAM role attached to the instance profile. Ref: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
  name          = "${var.resource_prefix}-ec2-launch-template"
  key_name      = (var.public_key == "") ? null : aws_key_pair.runner-pubkey[0].key_name
  instance_type = var.deployment_options.InstanceType
  user_data     = data.cloudinit_config.orthconfig.rendered
  image_id      = data.aws_ami.amazon_linux_ami.id
  iam_instance_profile {
    name = aws_iam_instance_profile.inst_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  block_device_mappings {
    device_name = data.aws_ami.amazon_linux_ami.root_device_name
    ebs {
      volume_size = 20
      encrypted   = true
      kms_key_id  = var.custom_key_arn
    }
  }
  depends_on = [aws_iam_role.ec2_iam_role]

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "aws_network_interface" "orthanc_ec2_nics" {
  for_each        = toset(var.vpc_config.public_subnet_cidr_blocks)
  subnet_id       = var.vpc_config.public_subnet_ids[each.value]
  security_groups = values(aws_security_group.ec2_sgs)[*].id
  tags            = { Name = "${var.resource_prefix}-EC2-Business-Interface-${var.vpc_config.public_subnet_ids[each.value]}" }
  depends_on      = [aws_security_group.ec2_sgs]
}

resource "aws_instance" "orthweb_instance" {
  #checkov:skip=CKV_AWS_79: IMDS defined in launch template
  #checkov:skip=CKV_AWS_8: Encryption configured in launch template
  for_each      = aws_network_interface.orthanc_ec2_nics
  ebs_optimized = true
  monitoring    = true
  network_interface {
    device_index         = 0
    network_interface_id = each.value.id
  }
  launch_template {
    id      = aws_launch_template.orthweb_launch_template.id
    version = aws_launch_template.orthweb_launch_template.latest_version
  }
  tags       = { Name = "${var.resource_prefix}-EC2-Instance-${var.vpc_config.public_subnet_ids[each.key]}" }
  depends_on = [aws_eip.orthweb_eip] # bootstrapping script provisions self-signed certificate using EIP's DNS name 

  #https://github.com/hashicorp/terraform-provider-aws/issues/5011
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "aws_eip" "orthweb_eip" {
  domain = "vpc"
  tags   = { Name = "${var.resource_prefix}-Floating-EIP" }
}

resource "aws_eip_association" "floating_eip_assoc" {
  allocation_id        = aws_eip.orthweb_eip.id
  network_interface_id = values(aws_network_interface.orthanc_ec2_nics)[0].id
}
