terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.59.0"
    }
  }
  required_version = ">= 1.5.7"
}

provider "aws" {
  # All provider details should be provided via environment variables:
  # export AWS_ACCESS_KEY_ID=
  # export AWS_SECRET_ACCESS_KEY=
  # export AWS_PROFILE=
  # export AWS_REGION=

  default_tags {
    tags = {
      Environment = var.CommonTags.Environment
      Owner       = var.CommonTags.Owner
      Application = "Orthanc"
    }
  }
}
