variable "vpn_config" {
  description = "VPN configuration"
  type = object({
    vpc_id              = string
    private_subnet_ids  = list(string)
    vpn_client_cidr     = string
    vpn_cert_cn_suffix  = string
    vpn_cert_valid_days = number
  })
}

variable "custom_key_arn" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}