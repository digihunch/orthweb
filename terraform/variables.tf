variable "pubkey_data" {
  type    = string
  default = null
}
variable "pubkey_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
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
    OrthancImg   = "osimis/orthanc:23.11.1"
    EnvoyImg     = "envoyproxy/envoy:v1.28.0"
    InstanceType = "t3.medium" # EBS-optimized instance type
  }
}
