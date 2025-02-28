variable "client_vpn_options" {
  description = "Options for Client VPN"
  type = object({
    vpc_id                     = string
    vpn_client_cidr            = string
    cert_domain_suffix         = string
    cert_validity_period_hours = number
  })
  default = {
    vpc_id                     = "vpc-1234567890"
    vpn_client_cidr            = "192.168.0.0/22"
    cert_domain_suffix         = "vpn.digihunch.com"
    cert_validity_period_hours = 87600 # 10 year
  }
}

variable "provider_tags" {
  description = "Tags to apply for every resource by default"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "info@digihunch.com"
  }
  validation {
    condition     = contains(["prd", "dev", "tst", "stg"], var.provider_tags.environment)
    error_message = "The environment code must be one of: prd, dev, tst, or stg"
  }
}