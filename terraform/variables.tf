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
variable "CommonTags" {
  description = "Tags for every resource."
  type        = map(any)
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
