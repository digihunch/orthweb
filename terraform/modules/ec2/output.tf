output "hosts_info" {
  value = {
    instance_ids = values(aws_instance.orthweb_instance)[*].id
    public_ips   = values(aws_instance.orthweb_instance)[*].public_ip
  }
}
output "eip_info" {
  value = {
    eip_dns = aws_eip.orthweb_eip.public_dns
  }
}


