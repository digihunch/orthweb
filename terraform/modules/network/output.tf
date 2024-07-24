output "vpc_info" {
  value = {
    vpc_id             = aws_vpc.orthmain.id
    public_subnet_ids  = aws_subnet.public_subnets[*].id
    private_subnet_ids = aws_subnet.private_subnets[*].id
  }
}

