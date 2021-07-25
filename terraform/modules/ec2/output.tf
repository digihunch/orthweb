output "bastion_info" {
  value = {
    public_dns_1 = aws_instance.orthweb_1.public_dns 
    public_dns_2 = aws_instance.orthweb_2.public_dns 
  } 
}
