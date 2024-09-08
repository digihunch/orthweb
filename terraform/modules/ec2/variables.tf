variable "public_key" {
  type      = string
  sensitive = true
}
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    vpc_id                    = string
    public_subnet_cidr_blocks = list(string)
    public_subnet_ids         = map(string)
    scu_cidr_block            = string
  })
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
variable "custom_key_arn" {
  type = string
}
variable "deployment_options" {
  type = map(any)
}
variable "resource_prefix" {
  type        = string
  description = "Uniq prefix of each resource"
}
