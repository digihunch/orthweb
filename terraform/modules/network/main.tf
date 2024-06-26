resource "aws_vpc" "orthmain" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = merge(var.resource_tags, { Name = "${var.resource_prefix}-MainVPC" })
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.orthmain.id
  tags   = merge(var.resource_tags, { Name = "${var.resource_prefix}-MainVPC-Default-SG" })
}

resource "aws_flow_log" "mainVPCflowlog" {
  log_destination          = var.vpc_flow_logging_bucket_arn
  log_destination_type     = "s3"
  traffic_type             = "REJECT"
  vpc_id                   = aws_vpc.orthmain.id
  max_aggregation_interval = 600
  destination_options {
    per_hour_partition = true
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-MainVPCFlowLog" })
}

resource "aws_subnet" "publicsubnet1" {
  #checkov:skip=CKV_AWS_130:This is a public subnet
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.public_subnet1_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags                    = merge(var.resource_tags, { Name = "${var.resource_prefix}-PublicSubnet1" })
}

resource "aws_subnet" "publicsubnet2" {
  #checkov:skip=CKV_AWS_130:This is a public subnet
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.public_subnet2_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags                    = merge(var.resource_tags, { Name = "${var.resource_prefix}-PublicSubnet2" })
}

resource "aws_subnet" "privatesubnet1" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.private_subnet1_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags                    = merge(var.resource_tags, { Name = "${var.resource_prefix}-PrivateSubnet1" })
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = var.private_subnet2_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags                    = merge(var.resource_tags, { Name = "${var.resource_prefix}-PrivateSubnet2" })
}

resource "aws_internet_gateway" "maingw" {
  vpc_id = aws_vpc.orthmain.id
  tags   = merge(var.resource_tags, { Name = "${var.resource_prefix}-MainGateway" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.orthmain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maingw.id
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-PublicRouteTable" })
}

resource "aws_route_table_association" "pubsub1_rt_assoc" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pubsub2_rt_assoc" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_main_route_table_association" "vpc_rt_assoc" {
  vpc_id         = aws_vpc.orthmain.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ep_secgroup" {
  name        = "${var.resource_prefix}-vpcep_sg"
  description = "security group for vpc endpoints"
  vpc_id      = aws_vpc.orthmain.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "allow access to https from VPC"
  }
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-S3EndPointSecurityGroup" })
}

resource "aws_vpc_endpoint" "s3_ep" {
  vpc_id            = aws_vpc.orthmain.id
  service_name      = "com.amazonaws.${data.aws_region.this.name}.s3"
  vpc_endpoint_type = "Gateway"
  tags               = merge(var.resource_tags, { Name = "${var.resource_prefix}-VPCEndPoint-S3" })
}

resource "aws_vpc_endpoint" "secmgr_ep" {
  vpc_id              = aws_vpc.orthmain.id 
  service_name        = "com.amazonaws.${data.aws_region.this.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ep_secgroup.id]
  subnet_ids          = [aws_subnet.privatesubnet1.id, aws_subnet.privatesubnet2.id]
  tags = merge(var.resource_tags, { Name = "${var.resource_prefix}-VPCEndPoint-SecMgr" })
}

