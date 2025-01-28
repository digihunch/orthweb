variable "custom_key_arn" {
  type = string
}
variable "resource_prefix" {
  type        = string
  description = "Uniq prefix of each resource"
}
variable "is_prod" {
  type        = bool
  description = "whether the resource is in prod environment"
  default     = false
}