output "role_info" {
  value = {
    ec2_iam_role_name = aws_iam_role.ec2_iam_role.name
  }
}
