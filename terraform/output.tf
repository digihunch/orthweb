output "host_info" {
  value       = join(", ", [for i in range(length(module.ec2.hosts_info.instance_ids)) : join("", [module.ec2.hosts_info.instance_ids[i], " (Public IP ", module.ec2.hosts_info.public_ips[i], ")"])])
  description = "Instance IDs and Public IPs of EC2 instances"
}
output "server_dns" {
  value       = format("%s %s", join(", ", [for pub_dns in module.ec2.hosts_info.public_dns : pub_dns]), "(HTTPS and DICOM TLS)")
  description = "DNS names of EC2 instances"
}
output "db_endpoint" {
  value       = join(":", [module.database.db_info.db_address, module.database.db_info.db_port])
  description = "Database endpiont (port 5432 only accessible privately from EC2 Instance)"
}
output "s3_bucket" {
  value       = module.storage.s3_info.bucket_domain_name
  description = "S3 bucket name for data storage"
}
