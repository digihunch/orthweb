#variable "amilut" {
#  type = map(any)
#  default = {
#    "us-east-1"      = "ami-0fc61db8544a617ed"
#    "us-west-1"      = "ami-09a7fe78668f1e2c0"
#    "ap-southeast-2" = "ami-08fdde86b93accf1c"
#  }
#}
variable "public_key" {
  type = string
}
variable "public_subnet_id" {
  type = string
}
variable "db_instance_id" {
  type = string
}
variable "s3_bucket_name" {
  type = string
}
variable "role_name" {
  type = string
}
variable "db_secret_arn" {
  type = string
}
variable "s3_key_arn" {
  type = string
}
variable "ep_service_name" {
  type = string
}
variable "resource_prefix" {
  type = string
}
variable "resource_tags" {
  type = map(any)
}
