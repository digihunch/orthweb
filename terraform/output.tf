output "host_info" {
  value = join(", ", [for i in range(length(module.ec2.hosts_info.instance_ids)) : join("", [module.ec2.hosts_info.instance_ids[i], "(", module.ec2.hosts_info.public_ips[i], ")"])])
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
