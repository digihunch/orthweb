variable "pubkey_data" {
  type = string
  default = null
}
variable "pubkey_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
variable "tag_suffix" {
  type = string
  default = "orthweb"
}
