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
variable "DockerImages" {
  description = "Docker Images"
  type = map(any)
  default = {
    OrthancImg = "osimis/orthanc:22.11.3"
    EnvoyImg = "envoyproxy/envoy:v1.22.5"
  }
}
