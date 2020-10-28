# orthcloud

The provider section assumes credentials stored in ~/.aws/credentials under default profile. To initialize, use aws configure with keys.

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

terraform init

terraform apply

terraform destroy
