variable "vpn_config" {
  description = "VPN configuration"
  type = object({
    vpc_id              = string
    vpc_cidr            = string
    vpn_client_cidr     = string
    vpn_cert_cn_suffix  = string
    private_subnet_ids  = list(string)
    vpn_cert_valid_days = number
  })
}

variable "resource_prefix" {
  type        = string
  description = "Uniq prefix of each resource"
}

variable "s3_bucket_name" {
  type = string
}