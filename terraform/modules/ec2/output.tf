output "primary_host_info" {
  value = {
    public_dns = data.aws_eip.public1_eip.public_dns 
  }
}
output "secondary_host_info" {
  value = {
    public_dns = data.aws_eip.public2_eip.public_dns 
  }
}
output "eip_info" {
  value = {
    eip_dns = data.aws_eip.orthweb_eip.public_dns
  }
}
