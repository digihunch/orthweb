data "aws_caller_identity" "current" {
  # no arguments
}

data "template_file" "myuserdata" {
  template = "${file("${path.cwd}/myuserdata.tpl")}"
  vars = {
    db_endpoint = "${aws_db_instance.postgres.endpoint}",
    aws_region = "${var.depregion}"
    sm_endpoint = aws_vpc_endpoint.secmgr.dns_entry[0]["dns_name"]
    sec_name = "${aws_secretsmanager_secret.secretDB.name}"
  }
}

resource "aws_iam_role" "inst_role" {
  name = "inst_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "InstanceRole"
  }
}

resource "aws_iam_instance_profile" "inst_profile" {
  name = "inst_profile"
  role = "${aws_iam_role.inst_role.name}"
}

resource "aws_iam_role_policy" "secret_reader_policy" {
  name = "secret_reader_policy"
  role = "${aws_iam_role.inst_role.id}"

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
        "${aws_secretsmanager_secret.secretDB.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_instance" "orthweb" {
  ami           = var.amilut[var.depregion]
  instance_type = "t2.micro"
  user_data     = "${data.template_cloudinit_config.orthconfig.rendered}"
  key_name      = var.depkey
  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
  subnet_id     = aws_subnet.primarysubnet.id
  depends_on = [aws_db_instance.postgres]
  iam_instance_profile = "${aws_iam_instance_profile.inst_profile.name}"
  tags = {
    Name = "OrthServer"
  }
}

data "template_cloudinit_config" "orthconfig" {
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.myuserdata.rendered}"
  }
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.cwd}/custom_userdata.sh")}"
  }
}

