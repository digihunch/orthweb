output "primary_host_info" {
  value = {
    instance_id = aws_instance.orthweb_primary.id
  }
}
output "secondary_host_info" {
  value = {
    instance_id = aws_instance.orthweb_secondary.id
  }
}
output "eip_info" {
  value = {
    eip_dns = data.aws_eip.orthweb_eip.public_dns
  }
}
