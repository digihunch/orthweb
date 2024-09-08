variable "pubkey_data" {
  type      = string
  default   = null
  sensitive = true
  nullable  = true
}
variable "pubkey_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
variable "scu_cidr_block" {
  type    = string
  default = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.scu_cidr_block, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}
variable "vpc_config" {
  type = object({
    vpc_cidr              = string
    az_count              = number
    public_subnet_pfxlen  = number
    private_subnet_pfxlen = number
  })
  default = {
    vpc_cidr              = "172.17.0.0/16"
    az_count              = 2
    public_subnet_pfxlen  = 24
    private_subnet_pfxlen = 22
  }
  validation {
    condition     = can(cidrhost(var.vpc_config.vpc_cidr, 32))
    error_message = "Input variable vpc_config.vpc_cidr must be a valid IPv4 CIDR."
  }
  validation {
    condition     = var.vpc_config.az_count >= 1 && var.vpc_config.az_count <= 3
    error_message = "Input variable vpc_config.az_count must be a numeric value between 1, 2 or 3"
  }
}
variable "CommonTags" {
  description = "Tags for every resource."
  type        = map(string)
  default = {
    Environment = "Dev"
    Owner       = "my@digihunch.com"
  }
}
variable "DeploymentOptions" {
  description = "Deployment Options"
  type        = map(any)
  default = {
    OrthancImg   = "orthancteam/orthanc:24.7.3"
    EnvoyImg     = "envoyproxy/envoy:v1.31.0"
    InstanceType = "t3.medium" # EBS-optimized instance type
  }
}
