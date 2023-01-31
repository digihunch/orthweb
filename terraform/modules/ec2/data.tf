data "aws_db_instance" "postgres" {
  db_instance_identifier = var.db_instance_id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_region" "this" {}

data "aws_s3_bucket" "orthbucket" {
  bucket = var.s3_bucket_name
}

data "aws_iam_role" "instance_role" {
  name = var.role_name
}

data "aws_secretsmanager_secret" "secretDB" {
  arn = var.db_secret_arn
}

data "aws_vpc_endpoint" "secmgr" {
  vpc_id       = var.vpc_config.vpc_id
  service_name = var.vpc_config.secret_ep_service_name
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_config.vpc_id
  service_name = var.vpc_config.s3_ep_service_name
}

data "cloudinit_config" "orthconfig" {
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata1.sh")
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/userdata2.tpl",{
      db_address       = data.aws_db_instance.postgres.address,
      db_port          = data.aws_db_instance.postgres.port,
      aws_region       = data.aws_region.this.name,
      sm_endpoint      = data.aws_vpc_endpoint.secmgr.dns_entry[0].dns_name,
      sec_name         = data.aws_secretsmanager_secret.secretDB.name,
      s3_endpoint      = data.aws_vpc_endpoint.s3.dns_entry[0].dns_name,
      s3_bucket        = data.aws_s3_bucket.orthbucket.bucket,
      orthanc_image    = var.deployment_options.OrthancImg,
      envoy_image      = var.deployment_options.EnvoyImg,
      floating_eip_dns = aws_eip.orthweb_eip.public_dns
    })
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata3.sh")
  }
}
