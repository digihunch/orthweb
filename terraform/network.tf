// data "aws_vpc" "default" {
//   default = true
// }
// 
// data "aws_subnet_ids" "all" {
//   vpc_id = data.aws_vpc.default.id
// }

resource "aws_vpc" "orthmain" {
  cidr_block       = "172.17.0.0/16"
  instance_tenancy = "default"
  tags = { 
    Name = "OrthmainVPC" 
  }
}

resource "aws_subnet" "primarysubnet" {
  vpc_id     = aws_vpc.orthmain.id
  cidr_block = "172.17.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PrimaryPublicSubnet"
  }
}

resource "aws_subnet" "privatesubnet1" {
  vpc_id     = aws_vpc.orthmain.id 
  cidr_block = "172.17.4.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id     = aws_vpc.orthmain.id 
  cidr_block = "172.17.5.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet2"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "dbsubnetgroup" 
  subnet_ids = [aws_subnet.privatesubnet1.id,aws_subnet.privatesubnet2.id]
}

resource "aws_internet_gateway" "maingw" {
  vpc_id     = aws_vpc.orthmain.id
  tags = {
    Name = "MainIntGtwy"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id     = aws_vpc.orthmain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maingw.id
  }
}
