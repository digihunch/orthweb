module "network" {
  source = "./modules/network"
  vpc_cidr_block = "172.17.0.0/16"
  public_subnet_cidr_block = "172.17.1.0/24"
  private_subnet1_cidr_block = "172.17.4.0/24"
  private_subnet2_cidr_block = "172.17.5.0/24"
  tag_suffix = "${var.tag-suffix}"
}

#module "ec2" {
#  source = "./modules/ec2"
#  tag_suffix = "${var.tag-suffix}"
#  pubkey_name = "${var.pubkey-name}"
#  public_subnet_id = module.network.vpc_info.public_subnet_id
#}
#
#module "secretmanager" {
#  source = "./modules/secmgr"
#  tag_suffix = "${var.tag-suffix}"
#}
#
#module "database" {
#  source = "./modules/database"
#  tag_suffix = "${var.tag-suffix}"
#}
#
#module "storage" {
#  source = "./modules/storage"
#  tag_suffix = "${var.tag-suffix}"
#}
#
