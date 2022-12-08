variable "public_key" {
  type = string
}
variable "vpc_config" {
  description = "VPC configuration"
  type        = map(any)
  default = {
    vpc_id                 = null
    public_subnet1_id      = null
    public_subnet2_id      = null
    secret_ep_service_name = null
    s3_ep_service_name     = null
#    eip_allocation_id      = null
  }
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
#variable "s3_key_arn" {
#  type = string
#}
variable "custom_key_arn" {
  type = string
}
variable "deployment_options" {
  type = map(any)
}
variable "resource_prefix" {
  type = string
}
variable "resource_tags" {
  type = map(any)
}
