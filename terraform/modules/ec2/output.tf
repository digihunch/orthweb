output "hosts_info" {
  value = {
    instance_ids = values(aws_instance.orthweb_instance)[*].id
    public_ips   = values(aws_instance.orthweb_instance)[*].public_ip
    public_dns   = values(aws_instance.orthweb_instance)[*].public_dns
  }
}

