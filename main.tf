# Tested with Terraform 0.13.5

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.12.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_instance" "orthweb" {
  ami           = "ami-0fc61db8544a617ed" 
  instance_type = "t3.micro"
  key_name      = "yi_cs"
  tags = {
    Name = "OrthServer"
  }
}

output "connstr" {
   value = aws_instance.orthweb.public_dns
}
