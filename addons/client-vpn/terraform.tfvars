provider_tags = {
  environment = "dev"
  owner       = "admin@digihunch.com"
}

client_vpn_options = {
  vpc_id                     = "vpc-07af4660a1dae5647"
  vpn_client_cidr            = "192.168.0.0/22"
  cert_validity_period_hours = 87600 # 10 year
  cert_domain_suffix         = "vpn.digihunch.com"
}