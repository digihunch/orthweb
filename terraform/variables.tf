variable "pubkey_data" {
  type    = string
  default = null
}
variable "pubkey_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
variable "scu_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}
variable "Tags" {
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
    OrthancImg   = "orthancteam/orthanc:24.7.2"
    EnvoyImg     = "envoyproxy/envoy:v1.30.4"
    InstanceType = "t3.medium" # EBS-optimized instance type
  }
}
