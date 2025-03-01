resource "random_pet" "prefix" {}

locals {
  vpc_pfxlen = parseint(regex("/(\\d+)$", var.network_config.vpc_cidr)[0], 10)
  # Calculate subnet size for each type of subnet per AZ, in the order of public subnet and private subnet
  subnet_sizes = [var.network_config.public_subnet_pfxlen - local.vpc_pfxlen, var.network_config.private_subnet_pfxlen - local.vpc_pfxlen]
  # Calculate the Subnet CIDRs for each type of subnet, in all AZs
  subnet_cidrs = cidrsubnets(var.network_config.vpc_cidr, flatten([for i in range(var.network_config.az_count) : local.subnet_sizes])...)
  # For each type of subnet, build a list of CIDRs for the subnet type in all AZs
  public_subnets_cidr_list  = [for idx, val in local.subnet_cidrs : val if idx % 2 == 0]
  private_subnets_cidr_list = [for idx, val in local.subnet_cidrs : val if idx % 2 == 1]
}

module "key" {
  # This encryption key is used to encrypt s3 bucket, database, secret manager entry, EC2 volume, etc
  source          = "./modules/key"
  resource_prefix = random_pet.prefix.id
}

module "storage" {
  source          = "./modules/storage"
  custom_key_arn  = module.key.custom_key_id
  resource_prefix = random_pet.prefix.id
  is_prod         = var.provider_tags.environment == "prd"
  depends_on      = [module.key]
}

module "network" {
  source = "./modules/network"
  network_cidr_blocks = {
    vpc_cidr_block             = var.network_config.vpc_cidr
    public_subnet_cidr_blocks  = local.public_subnets_cidr_list
    private_subnet_cidr_blocks = local.private_subnets_cidr_list
  }
  ifep_services               = var.network_config.interface_endpoints
  vpc_flow_logging_bucket_arn = module.storage.s3_info.logging_bucket_arn
  resource_prefix             = random_pet.prefix.id
}

module "database" {
  source = "./modules/database"
  vpc_config = {
    vpc_id             = module.network.vpc_info.vpc_id
    private_subnet_ids = module.network.vpc_info.private_subnet_ids
  }
  custom_key_arn  = module.key.custom_key_id
  resource_prefix = random_pet.prefix.id
  is_prod         = var.provider_tags.environment == "prd"
  depends_on      = [module.key]
}

module "ec2" {
  source         = "./modules/ec2"
  public_key     = var.ec2_config.PublicKeyData != null ? var.ec2_config.PublicKeyData : (fileexists(var.ec2_config.PublicKeyPath) ? file(var.ec2_config.PublicKeyPath) : "")
  role_name      = "${random_pet.prefix.id}-InstanceRole"
  db_info        = module.database.db_info
  secret_info    = module.database.secret_info
  s3_bucket_name = module.storage.s3_info.bucket_name
  custom_key_arn = module.key.custom_key_id
  vpc_config = {
    vpc_id                    = module.network.vpc_info.vpc_id
    public_subnet_ids         = module.network.vpc_info.public_subnet_ids
    public_subnet_cidr_blocks = local.public_subnets_cidr_list
    dcm_cli_cidrs             = (var.network_config.vpn_client_cidr == "" || var.network_config.vpn_client_cidr == null) ? var.network_config.dcm_cli_cidrs : concat(var.network_config.dcm_cli_cidrs, [var.network_config.vpn_client_cidr])
    web_cli_cidrs             = var.network_config.web_cli_cidrs
  }
  ec2_config = {
    InstanceType = var.ec2_config.InstanceType
  }
  deployment_options = var.deployment_options
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.database, module.storage, module.network]
}

module "client_vpn" {
  source = "./modules/client-vpn"
  count  = (var.network_config.vpn_client_cidr == "" || var.network_config.vpn_client_cidr == null) ? 0 : 1
  vpn_config = {
    vpc_id              = module.network.vpc_info.vpc_id
    vpc_cidr            = var.network_config.vpc_cidr
    private_subnet_ids  = module.network.vpc_info.private_subnet_ids
    vpn_client_cidr     = var.network_config.vpn_client_cidr
    vpn_cert_cn_suffix  = var.network_config.vpn_cert_cn_suffix
    vpn_cert_valid_days = var.network_config.vpn_cert_valid_days
  }

  s3_bucket_name  = module.storage.s3_info.bucket_name
  resource_prefix = random_pet.prefix.id
  depends_on      = [module.network]
}