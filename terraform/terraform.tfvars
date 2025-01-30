network_config = {
  vpc_cidr              = "172.17.0.0/16"
  scu_cidr              = "0.0.0.0/0"
  az_count              = 2
  public_subnet_pfxlen  = 24
  private_subnet_pfxlen = 22
  interface_endpoints   = []
}
provider_tags = {
  environment = "dev"
  owner       = "admin@digihunch.com"
}
deployment_options = {
  InstanceType = "t3.medium"
  ConfigRepo   = "https://github.com/digihunchinc/orthanc-config.git"
  SiteName     = null
  InitCommand  = "echo Custom Init Command && cd orthanc-config && make aws"
}
