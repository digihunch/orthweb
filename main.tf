# Terraform 0.13.5

provider "aws" {
  region = "us-east-1"
  profile = "default"
  shared_credentials_file = "~/.aws/credentials"
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
