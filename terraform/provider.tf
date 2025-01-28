terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }
  required_version = ">= 1.5.7"
}

provider "aws" {
  default_tags {
    tags = {
      Environment = var.provider_tags.environment
      Owner       = var.provider_tags.owner
      Application = "Orthanc"
    }
  }
}
