output "host1info" {
  value = "ec2-user@${module.ec2.bastion_info.public_dns_1}"
}
output "host2info" {
  value = "ec2-user@${module.ec2.bastion_info.public_dns_2}"
}
output "dbinfo" {
  value = module.database.db_info.db_endpoint
}
output "s3bucket" {
  value = module.storage.s3_info.bucket_domain_name 
}
