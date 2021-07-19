resource "aws_vpc" "orthmain" {
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC-${var.tag_suffix}"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = "${var.public_subnet_cidr_block}"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${var.tag_suffix}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "privatesubnet1" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = "${var.private_subnet1_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "PrivateSubnet1-${var.tag_suffix}"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = "${var.private_subnet2_cidr_block}"
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



resource "aws_security_group" "orthsecgrp" {
  name        = "orth_sg"
  description = "security group for orthanc"
  vpc_id      = aws_vpc.orthmain.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Orthanc Web"
    from_port   = 8042
    to_port     = 8042
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "DICOM Image"
    from_port   = 11112
    to_port     = 11112
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "WorkloadSecurityGroup-${var.tag_suffix}"
  }
}

