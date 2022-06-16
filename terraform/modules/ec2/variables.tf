variable "public_key" {
  type = string
}
variable "ssh_client_cidr_block" {
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
variable "s3_integration" {
  type = bool
  default = false
}
variable "resource_prefix" {
  type = string
}
variable "resource_tags" {
  type = map(any)
}
