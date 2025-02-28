variable "client_vpn_options" {
  description ="Options for Client VPN"
  type = object({
    vpc_id = string
    vpn_client_cidr = string
    cert_validity_period_hours = number
  })
  default = {
    vpc_id = "vpc-07af4660a1dae5647"
    vpn_client_cidr = "192.168.0.0/22"
    cert_validity_period_hours = 87600 # 10 year
  }

}