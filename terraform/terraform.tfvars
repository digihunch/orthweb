ec2_config = {
  InstanceType  = "t3.medium"
  PublicKeyData = null
  PublicKeyPath = "~/.ssh/id_rsa.pub"
}
network_config = {
  vpc_cidr              = "172.17.0.0/16"
  dcm_cli_cidrs         = ["0.0.0.0/0"]
  web_cli_cidrs         = ["0.0.0.0/0"]
  az_count              = 2
  public_subnet_pfxlen  = 24
  private_subnet_pfxlen = 22
  interface_endpoints   = []
  vpn_client_cidr       = "" # 192.168.0.0/22
  vpn_cert_cn_suffix    = "vpn.digihunch.com"
  vpn_cert_valid_days   = 3650
}
provider_tags = {
  environment = "dev"
  owner       = "admin@digihunch.com"
}
deployment_options = {
  ConfigRepo     = "https://github.com/digihunchinc/orthanc-config.git"
  CWLogRetention = 3
  EnableCWLog    = false
  SiteName       = null
  InitCommand    = "pwd && echo Custom Command && make aws"
}
