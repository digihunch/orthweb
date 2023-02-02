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
    Owner       = "my@email.com"
  }
}
variable "DeploymentOptions" {
  description = "Deployment Options"
  type        = map(any)
  default = {
    OrthancImg   = "osimis/orthanc:22.12.2"
    EnvoyImg     = "envoyproxy/envoy:v1.25.0"
    InstanceType = "t3.medium" # EBS-optimized instance type
  }
}
