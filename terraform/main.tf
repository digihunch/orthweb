resource "random_pet" "prefix" {}

module "iam_role" {
  source          = "./modules/role"
  resource_tags   = var.Tags
  resource_prefix = random_pet.prefix.id
}

module "storage" {
  source          = "./modules/storage"
  role_name       = module.iam_role.role_info.ec2_iam_role_name
  custom_key_arn  = module.secret.custom_key_id
  resource_tags   = var.Tags
  resource_prefix = random_pet.prefix.id
  depends_on      = [module.iam_role]
}

module "network" {
  source                      = "./modules/network"
  vpc_cidr_block              = "172.27.0.0/16"
  public_subnet1_cidr_block   = "172.27.3.0/24"
  public_subnet2_cidr_block   = "172.27.5.0/24"
  private_subnet1_cidr_block  = "172.27.4.0/24"
  private_subnet2_cidr_block  = "172.27.6.0/24"
  vpc_flow_logging_bucket_arn = module.storage.s3_info.logging_bucket_arn
  resource_tags               = var.Tags
  resource_prefix             = random_pet.prefix.id
}

module "secret" {
  source             = "./modules/secret"
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
  db_secret_id       = module.secret.secret_info.db_secret_id
  custom_key_arn     = module.secret.custom_key_id
  resource_tags      = var.Tags
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.secret]
}

module "ec2" {
  source         = "./modules/ec2"
  public_key     = var.pubkey_data != null ? var.pubkey_data : (fileexists(var.pubkey_path) ? file(var.pubkey_path) : "")
  role_name      = module.iam_role.role_info.ec2_iam_role_name
  db_instance_id = module.database.db_info.db_instance_id
  s3_bucket_name = module.storage.s3_info.bucket_name
  db_secret_arn  = module.secret.secret_info.db_secret_arn
  custom_key_arn = module.secret.custom_key_id
  vpc_config = {
    vpc_id                 = module.network.vpc_info.vpc_id
    public_subnet1_id      = module.network.vpc_info.public_subnet1_id
    public_subnet2_id      = module.network.vpc_info.public_subnet2_id
    s3_ep_service_name     = module.network.vpc_info.s3_vpc_ep_service_name
    secret_ep_service_name = module.secret.secret_info.ep_service_name
  }
  deployment_options = var.DeploymentOptions
  resource_tags      = var.Tags
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.iam_role, module.database, module.storage, module.network]
}
