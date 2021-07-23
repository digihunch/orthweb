variable "aws_provider_access_key" {
  type = string
  default = null
}
variable "aws_provider_secret_key" {
  type = string
  default = null
}
variable "public_key" {
  type = string
  default = null
}
variable "local_pubkey_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "tag_suffix" {
  type = string
  default = "orthweb"
}
