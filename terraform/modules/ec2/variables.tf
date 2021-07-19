variable "amilut" {
  type = map(any)
  default = {
    "us-east-1"      = "ami-0fc61db8544a617ed"
    "us-west-1"      = "ami-09a7fe78668f1e2c0"
    "ap-southeast-2" = "ami-08fdde86b93accf1c"
  }
}
variable "pubkey_name" {
  type = string
}
variable "tag_suffix" {
  type = string
}
variable "public_subnet_id" {
  type = string
}