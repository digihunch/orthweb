terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.12.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region  = var.region
  access_key = var.aws_provider_access_key
  secret_key = var.aws_provider_secret_key
  # default profile will be used if access_key and secret_key are null
  profile = "ylu"
}
