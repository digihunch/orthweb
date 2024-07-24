variable "network_cidr_blocks" {
  description = "CIDR blocks at VPC and subnet levels"
  type = object({
    vpc_cidr_block             = string
    public_subnet_cidr_blocks  = list(string)
    private_subnet_cidr_blocks = list(string)
  })
}
variable "ifep_services" {
  type    = list(string)
  default = ["sts", "secretsmanager"]
}
variable "vpc_flow_logging_bucket_arn" {
  type = string
}
variable "resource_prefix" {
  type        = string
  description = "Uniq prefix of each resource"
}
