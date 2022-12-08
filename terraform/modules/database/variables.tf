variable "private_subnet1_id" {
  type = string
}
variable "private_subnet2_id" {
  type = string
}
variable "db_secret_id" {
  type = string
}
variable "custom_key_arn" {
  type = string
}
variable "resource_prefix" {
  type = string
}
variable "resource_tags" {
  type = map(any)
}
