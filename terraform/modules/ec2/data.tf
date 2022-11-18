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
  vpc_id       = data.aws_subnet.public_subnet.vpc_id
  service_name = var.secret_ep_service_name
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_subnet.public_subnet.vpc_id
  service_name = var.s3_ep_service_name
}

data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

data "template_file" "userdata2" {
  template = file("${path.module}/userdata2.tpl")
  vars = {
    db_address  = data.aws_db_instance.postgres.address
    db_port     = data.aws_db_instance.postgres.port
    aws_region  = data.aws_region.this.name
    sm_endpoint = data.aws_vpc_endpoint.secmgr.dns_entry[0].dns_name
    sec_name    = data.aws_secretsmanager_secret.secretDB.name
    s3_endpoint = data.aws_vpc_endpoint.s3.dns_entry[0].dns_name
    s3_bucket   = data.aws_s3_bucket.orthbucket.bucket
    orthanc_image = var.docker_images.OrthancImg
    envoy_image = var.docker_images.EnvoyImg
  }
}

data "template_cloudinit_config" "orthconfig" {
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata1.sh")
  }
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata2.rendered
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata3.sh")
  }
}
