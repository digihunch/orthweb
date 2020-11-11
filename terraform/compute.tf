
data "template_file" "myuserdata" {
  template = "${file("${path.cwd}/myuserdata.tpl")}"
  vars = {
    db_endpoint = "${aws_db_instance.postgres.endpoint}"
  }
}

provider "aws" {
  region  = var.depregion
  profile = "default"
}

resource "aws_instance" "orthweb" {
  ami           = var.amilut[var.depregion]
  instance_type = "t2.micro"
  user_data     = "${data.template_cloudinit_config.orthconfig.rendered}"
  key_name      = var.depkey
  vpc_security_group_ids = [aws_security_group.orthsecgrp.id]
  subnet_id     = aws_subnet.primarysubnet.id
  depends_on = [aws_db_instance.postgres]
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

