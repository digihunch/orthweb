output "primary_host_info" {
  value = {
    instance_id = values(aws_instance.orthweb_instance)[0].id
  }
}
output "secondary_host_info" {
  value = {
    instance_id = values(aws_instance.orthweb_instance)[1].id
  }
}
output "eip_info" {
  value = {
    eip_dns = aws_eip.orthweb_eip.public_dns
  }
}
