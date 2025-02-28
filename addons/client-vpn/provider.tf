terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.84.0"
    }
  }

  required_version = ">= 1.10"
}

provider "tls" {}

provider "aws" {
  default_tags {
    tags = {
      Environment = var.provider_tags.environment
      Owner       = var.provider_tags.owner
      Application = "Client-VPN-Addon"
    }
  }
}