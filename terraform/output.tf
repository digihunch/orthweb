output "primary_host" {
  value = "ec2-user@${module.ec2.primary_host_info.public_dns} (SSH)"
}
output "secondary_host" {
  value = "ec2-user@${module.ec2.secondary_host_info.public_dns} (SSH)"
}
output "site_address" {
  value = "${module.ec2.eip_info.eip_dns} (HTTPS and DICOM TLS)"
}
output "db_endpoint" {
  value = "${module.database.db_info.db_endpoint} (private access)"
}
output "s3_bucket" {
  value = "${module.storage.s3_info.bucket_domain_name} (private access)"
}
