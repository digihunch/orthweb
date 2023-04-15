output "vpc_info" {
  value = {
    vpc_id                 = aws_vpc.orthmain.id
    public_subnet1_id      = aws_subnet.publicsubnet1.id
    public_subnet2_id      = aws_subnet.publicsubnet2.id
    private_subnet1_id     = aws_subnet.privatesubnet1.id
    private_subnet2_id     = aws_subnet.privatesubnet2.id
    s3_vpc_ep_service_name = aws_vpc_endpoint.s3_ep.service_name
    secmgr_vpc_ep_service_name = aws_vpc_endpoint.secmgr_ep.service_name
  }
}
