# this resources warrants a module of its own because it is shared by two other modules

resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.resource_prefix}-iamrole-for-ec2-instance"

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
  tags               = merge(var.resource_tags, { Name = "${var.resource_prefix}-IAMRole" })
}

resource "aws_iam_role_policy_attachment" "ec2-iam-role-ssm-policy-attach" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
