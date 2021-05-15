resource "aws_vpc" "orthmain" {
  cidr_block       = "172.17.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
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

data "aws_availability_zones" "available" {}

resource "aws_subnet" "privatesubnet1" {
  vpc_id     = aws_vpc.orthmain.id 
  cidr_block = "172.17.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id     = aws_vpc.orthmain.id 
  cidr_block = "172.17.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[2]
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

resource "aws_route_table_association" "pubsub_rt_assoc" {
  subnet_id = aws_subnet.primarysubnet.id 
  route_table_id = aws_route_table.public_route_table.id 
}
 
resource "aws_main_route_table_association" "vpc_rt_assoc" {
  vpc_id =  aws_vpc.orthmain.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_vpc_endpoint" "secmgr" {
  vpc_id = aws_vpc.orthmain.id
  service_name = "com.amazonaws.${var.depregion}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.epsecgroup.id]
  subnet_ids = [aws_subnet.primarysubnet.id] 
  # For each interface endpoint, you can choose one subnet per AZ. 
}


