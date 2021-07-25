resource "random_id" "randsuffix" {
  byte_length = 8
}

module "iam_role" {
  source = "./modules/role"
  tag_suffix = var.tag_suffix
}

module "network" {
  source = "./modules/network"
  vpc_cidr_block = "172.17.0.0/16"
  public_subnet1_cidr_block = "172.17.1.0/24"
  public_subnet2_cidr_block = "172.17.2.0/24"
  private_subnet1_cidr_block = "172.17.4.0/24"
  private_subnet2_cidr_block = "172.17.5.0/24"
  tag_suffix = var.tag_suffix
}

module "secretmanager" {
  source = "./modules/secmgr"
  public_subnet1_id = module.network.vpc_info.public_subnet1_id
  public_subnet2_id = module.network.vpc_info.public_subnet2_id
  tag_suffix = var.tag_suffix
  name_suffix = random_id.randsuffix.hex
}

module "database" {
  source = "./modules/database"
  tag_suffix = var.tag_suffix
  private_subnet1_id = module.network.vpc_info.private_subnet1_id
  private_subnet2_id = module.network.vpc_info.private_subnet2_id
  db_secret_id = module.secretmanager.secret_info.db_secret_id
  depends_on = [module.secretmanager]
}

module "storage" {
  source = "./modules/storage"
  role_name = module.iam_role.role_info.ec2_iam_role_name 
  tag_suffix = var.tag_suffix
  name_suffix = random_id.randsuffix.hex
  depends_on = [module.iam_role]
}

module "ec2" {
  source = "./modules/ec2"
  tag_suffix = var.tag_suffix
  public_key = coalesce(var.public_key, data.local_file.pubkey.content) 
  role_name = module.iam_role.role_info.ec2_iam_role_name
  db_instance_id = module.database.db_info.db_instance_id
  s3_bucket_name = module.storage.s3_info.bucket_name
  db_secret_arn = module.secretmanager.secret_info.db_secret_arn
  s3_key_arn = module.storage.s3_info.key_arn
  ep_service_name = module.secretmanager.secret_info.ep_service_name
  public_subnet1_id = module.network.vpc_info.public_subnet1_id
  public_subnet2_id = module.network.vpc_info.public_subnet2_id
  depends_on = [module.iam_role, module.database, module.storage]
}
