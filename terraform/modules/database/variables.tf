variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    vpc_id             = string
    private_subnet_ids = list(string)
  })
}
variable "psql_engine_family" {
  type    = string
  default = "postgres17"
}
variable "psql_engine_version" {
  type    = string
  default = "17.2"
}
variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"
  # t2.micro does not support encryption at rest
}
variable "db_instance_storage_type" {
  type    = string
  default = "gp3"    # magnetic drive minimum 5g storage
}
variable "db_instance_allocated_storage" {
  type    = number
  default = 30   
}
variable "custom_key_arn" {
  type = string
}
variable "resource_prefix" {
  type        = string
  description = "Uniq prefix of each resource"
}
variable "is_prod" {
  type        = bool
  description = "whether the resource is in prod environment"
  default     = false
}
