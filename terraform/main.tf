resource "random_pet" "prefix" {}

module "iam_role" {
  source          = "./modules/role"
  resource_tags   = var.Tags
  resource_prefix = random_pet.prefix.id
}

module "network" {
  source                     = "./modules/network"
  vpc_cidr_block             = "172.27.0.0/16"
  public_subnet1_cidr_block  = "172.27.3.0/24"
  public_subnet2_cidr_block  = "172.27.5.0/24"
  private_subnet1_cidr_block = "172.27.4.0/24"
  private_subnet2_cidr_block = "172.27.6.0/24"
  resource_tags              = var.Tags
  resource_prefix            = random_pet.prefix.id
}

module "secretmanager" {
  source             = "./modules/secmgr"
  private_subnet1_id = module.network.vpc_info.private_subnet1_id
  private_subnet2_id = module.network.vpc_info.private_subnet2_id
  role_name          = module.iam_role.role_info.ec2_iam_role_name
  resource_tags      = var.Tags
  resource_prefix    = random_pet.prefix.id
}

module "database" {
  source             = "./modules/database"
  private_subnet1_id = module.network.vpc_info.private_subnet1_id
  private_subnet2_id = module.network.vpc_info.private_subnet2_id
  db_secret_id       = module.secretmanager.secret_info.db_secret_id
  resource_tags      = var.Tags
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.secretmanager]
}

module "storage" {
  source          = "./modules/storage"
  role_name       = module.iam_role.role_info.ec2_iam_role_name
  resource_tags   = var.Tags
  resource_prefix = random_pet.prefix.id
  depends_on      = [module.iam_role]
}

module "ec2" {
  source         = "./modules/ec2"
  public_key     = var.pubkey_data != null ? var.pubkey_data : (fileexists(var.pubkey_path) ? file(var.pubkey_path) : "")
  role_name      = module.iam_role.role_info.ec2_iam_role_name
  db_instance_id = module.database.db_info.db_instance_id
  s3_bucket_name = module.storage.s3_info.bucket_name
  db_secret_arn  = module.secretmanager.secret_info.db_secret_arn
  s3_key_arn     = module.storage.s3_info.key_arn
  vpc_config = {
    vpc_id                 = module.network.vpc_info.vpc_id
    public_subnet1_id      = module.network.vpc_info.public_subnet1_id
    public_subnet2_id      = module.network.vpc_info.public_subnet2_id
    s3_ep_service_name     = module.network.vpc_info.s3_vpc_ep_service_name
    secret_ep_service_name = module.secretmanager.secret_info.ep_service_name
    eip_allocation_id      = module.network.eip_info.floating_allocation_id
  }
  deployment_options = var.DeploymentOptions
  resource_tags      = var.Tags
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.iam_role, module.database, module.storage, module.network]
}
