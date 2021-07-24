# this resources warrants a module of its own because it is shared by two other modules

resource "aws_iam_role" "ec2_iam_role" {
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
    Name = "IAMRole-${var.tag_suffix}"
  }
}
