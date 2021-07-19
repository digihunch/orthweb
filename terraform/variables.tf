variable "aws_provider_access_key" {
  type = string
  default = null
}
variable "aws_provider_secret_key" {
  type = string
  default = null
}
variable "pubkey_name" {
  type    = string
  default = "anamac"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "tag_suffix" {
  type = string
  default = "orthweb"
}
