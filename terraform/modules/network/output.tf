output "vpc_info" {
  value = {
    vpc_id             = aws_vpc.orthmain.id
    public_subnet_ids  = { for k, v in aws_subnet.public_subnets : v.cidr_block => v.id }
    private_subnet_ids = values(aws_subnet.private_subnets)[*].id
  }
}

