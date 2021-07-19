output "bastion_info" {
  value = aws_instance.orthweb.public_dns 
}