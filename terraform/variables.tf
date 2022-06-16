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
variable "UseS3Storage" {
  type = bool
  default = false
}
variable "cli_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}
