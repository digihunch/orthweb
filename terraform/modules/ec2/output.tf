output "bastion_info" {
  value = {
    public_dns = aws_instance.orthweb.public_dns
  }
}
