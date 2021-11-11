variable "vpc_cidr_block" {
  type = string
}
variable "public_subnet1_cidr_block" {
  type = string
}
variable "public_subnet2_cidr_block" {
  type = string
}
variable "private_subnet1_cidr_block" {
  type = string
}
variable "private_subnet2_cidr_block" {
  type = string
}
variable "resource_prefix" {
  type = string
}
variable "resource_tags" {
  type = map(any)
}
