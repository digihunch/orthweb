data "aws_db_instance" "postgres" {
  #db_instance_identifier = "${var.db_instance_name}"
  db_instance_identifier = "${var.db_instance_id}"
}

data "aws_s3_bucket" "orthbucket" {
  bucket = "${var.s3_bucket_name}"
}

data "aws_iam_role" "instance_role" {
  name = "${var.role_name}"
}

data "aws_secretsmanager_secret" "secretDB" {
  arn = "${var.db_secret_arn}"
}

data "aws_vpc_endpoint" "secmgr" {
  vpc_id = data.aws_subnet.public_subnet.vpc_id
  service_name = "${var.ep_service_name}"
}

data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

data "template_file" "myuserdata" {
  template = file("${path.module}/myuserdata.tpl")
  vars = {
    db_address  = "${data.aws_db_instance.postgres.address}",
    db_port     = "${data.aws_db_instance.postgres.port}",
    aws_region  = "${var.region}"
    sm_endpoint = data.aws_vpc_endpoint.secmgr.dns_entry[0]["dns_name"]
    sec_name    = "${data.aws_secretsmanager_secret.secretDB.name}"
    s3_bucket   = "${data.aws_s3_bucket.orthbucket.bucket}"
  }
}

data "template_cloudinit_config" "orthconfig" {
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.myuserdata.rendered
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/custom_userdata.sh")
  }
}
