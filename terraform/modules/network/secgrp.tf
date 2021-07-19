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
    Name = "allow orthanc"
  }
}

resource "aws_security_group" "dbsecgroup" {
  name        = "orthdb_sg"
  description = "postgres security group"
  vpc_id      = aws_vpc.orthmain.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow traffic to postgresdb"
  }
}

resource "aws_security_group" "epsecgroup" {
  name        = "vpcep_sg"
  description = "security group for vpc endpoint"
  vpc_id      = aws_vpc.orthmain.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allowing outgoing traffic only."
  }
}
