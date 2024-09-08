data "aws_availability_zones" "this" {}
data "aws_region" "this" {}

resource "aws_vpc" "orthmain" {
  cidr_block           = var.network_cidr_blocks.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = { Name = "${var.resource_prefix}-MainVPC" }
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
  tags = { Name = "${var.resource_prefix}-MainVPCFlowLog" }
}

# Instances are placed in public subnet. Private for DB subnets and endpoint interfaces.
# Private subnets do not need to access the Internet, hence no NAT Gateway

resource "aws_subnet" "public_subnets" {
  #checkov:skip=CKV_AWS_130: For public subnet, assign public IP by default
  for_each = {
    for cidr in var.network_cidr_blocks.public_subnet_cidr_blocks :
    substr(data.aws_availability_zones.this.names[index(var.network_cidr_blocks.public_subnet_cidr_blocks, cidr)], -2, -1) => {
      subnet_cidr_block = cidr
      availability_zone = data.aws_availability_zones.this.names[index(var.network_cidr_blocks.public_subnet_cidr_blocks, cidr)]
    }
  }
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = each.value.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = each.value.availability_zone
  tags                    = { Name = "${var.resource_prefix}-PublicSubnet${each.key}" }
}

resource "aws_subnet" "private_subnets" {
  for_each = {
    for cidr in var.network_cidr_blocks.private_subnet_cidr_blocks :
    substr(data.aws_availability_zones.this.names[index(var.network_cidr_blocks.private_subnet_cidr_blocks, cidr)], -2, -1) => {
      subnet_cidr_block = cidr
      availability_zone = data.aws_availability_zones.this.names[index(var.network_cidr_blocks.private_subnet_cidr_blocks, cidr)]
    }
  }
  vpc_id                  = aws_vpc.orthmain.id
  cidr_block              = each.value.subnet_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = each.value.availability_zone
  tags                    = { Name = "${var.resource_prefix}-PrivateSubnet${each.key}" }
}
resource "aws_internet_gateway" "maingw" {
  vpc_id = aws_vpc.orthmain.id
  tags   = { Name = "${var.resource_prefix}-MainGateway" }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.orthmain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maingw.id
  }
  tags = { Name = "${var.resource_prefix}-PublicRouteTable" }
}

resource "aws_route_table_association" "pubsub_rt_assocs" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.key].id
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
    cidr_blocks = [var.network_cidr_blocks.vpc_cidr_block]
    description = "allow access to https from VPC"
  }
  tags = { Name = "${var.resource_prefix}-S3EndPointSecurityGroup" }
}

resource "aws_vpc_endpoint" "s3_ep" {
  vpc_id            = aws_vpc.orthmain.id
  service_name      = "com.amazonaws.${data.aws_region.this.name}.s3"
  vpc_endpoint_type = "Gateway"
  tags              = { Name = "${var.resource_prefix}-s3-gwep" }
}

resource "aws_vpc_endpoint" "standard_interface_endpoints" {
  for_each            = toset(var.ifep_services)
  vpc_id              = aws_vpc.orthmain.id
  service_name        = "com.amazonaws.${data.aws_region.this.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_subnets)[*].id
  tags                = { Name = "${var.resource_prefix}-${each.key}-ifep" }
}


