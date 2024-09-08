output "host_info" {
  value = "Primary:${module.ec2.primary_host_info.instance_id}    Secondary:${module.ec2.secondary_host_info.instance_id} (private SSH access as ec2-user)"
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