output "hostinfo" {
  value = "ec2-user@${module.ec2.bastion_info.public_dns}"
}
output "dbinfo" {
  value = module.database.db_info.db_endpoint
}
output "s3bucket" {
  value = module.storage.s3_info.bucket_domain_name
}
