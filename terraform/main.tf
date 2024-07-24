resource "random_pet" "prefix" {}

module "key" {
  # This encryption key is used to encrypt s3 bucket, database, secret manager entry, EC2 volume, etc
  source          = "./modules/key"
  resource_prefix = random_pet.prefix.id
}

module "storage" {
  source          = "./modules/storage"
  custom_key_arn  = module.key.custom_key_id
  resource_prefix = random_pet.prefix.id
  depends_on      = [module.key]
}

module "network" {
  source = "./modules/network"
  network_cidr_blocks = {
    vpc_cidr_block             = "172.27.0.0/16"
    public_subnet_cidr_blocks  = ["172.27.3.0/24", "172.27.5.0/24"]
    private_subnet_cidr_blocks = ["172.27.4.0/24", "172.27.6.0/24"]
  }
  ifep_services = ["secretsmanager"]
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
  depends_on      = [module.key]
}

module "ec2" {
  source         = "./modules/ec2"
  public_key     = var.pubkey_data != null ? var.pubkey_data : (fileexists(var.pubkey_path) ? file(var.pubkey_path) : "")
  role_name      = "${random_pet.prefix.id}-InstanceRole"
  db_instance_id = module.database.db_info.db_instance_id
  s3_bucket_name = module.storage.s3_info.bucket_name
  db_secret_arn  = module.database.secret_info.db_secret_arn
  custom_key_arn = module.key.custom_key_id
  vpc_config = {
    vpc_id            = module.network.vpc_info.vpc_id
    public_subnet_ids = module.network.vpc_info.public_subnet_ids
    scu_cidr_block    = var.scu_cidr_block
  }
  deployment_options = var.DeploymentOptions
  resource_prefix    = random_pet.prefix.id
  depends_on         = [module.database, module.storage, module.network]
}
