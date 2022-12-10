data "aws_caller_identity" "current" {
  # no arguments
}
data "aws_region" "this" {}
data "aws_iam_role" "instance_role" {
  name = var.role_name
}
