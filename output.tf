output "hostinfo" {
   value = "ec2-user@${aws_instance.orthweb.public_dns}"
}
