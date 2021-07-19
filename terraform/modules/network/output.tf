output "vpc_info" {
  value = {
    vpc_id = aws_vpc.orthmain.id
    public_subnet_id = aws_subnet.publicsubnet.id
    private_subnet_id = aws_subnet.privatesubnet1.id
    private_subnet_id = aws_subnet.privatesubnet2.id
  }
}
