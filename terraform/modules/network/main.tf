resource "aws_vpc" "orthmain" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC-${var.tag_suffix}"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${var.tag_suffix}"
  }
}

resource "aws_subnet" "privatesubnet1" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.private_subnet1_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "PrivateSubnet1-${var.tag_suffix}"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.private_subnet2_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "PrivateSubnet2-${var.tag_suffix}"
  }
}

resource "aws_internet_gateway" "maingw" {
  vpc_id = aws_vpc.orthmain.id
  tags = {
    Name = "MainGateway-${var.tag_suffix}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.orthmain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maingw.id
  }
}

resource "aws_route_table_association" "pubsub_rt_assoc" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_main_route_table_association" "vpc_rt_assoc" {
  vpc_id         = aws_vpc.orthmain.id
  route_table_id = aws_route_table.public_route_table.id
}

