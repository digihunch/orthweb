output "vpc_info" {
  value = {
    vpc_id = aws_vpc.orthmain.id
    public_subnet1_id = aws_subnet.publicsubnet1.id
    public_subnet2_id = aws_subnet.publicsubnet2.id
    private_subnet1_id = aws_subnet.privatesubnet1.id
    private_subnet2_id = aws_subnet.privatesubnet2.id
  }
}
