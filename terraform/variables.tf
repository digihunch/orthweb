variable "aws_provider_access_key" {
  type = string
  default = null
}
variable "aws_provider_secret_key" {
  type = string
  default = null
}
variable "depkey" {
  type    = string
  default = "cskey"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "tag-suffix" {
  type = string
  default = "orthweb"
}
