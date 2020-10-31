resource "aws_security_group" "orthsecgrp" {
  name        = "orth_sg"
  description = "security group for orthanc"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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
    description = "Orthanc Image"
    from_port   = 4242
    to_port     = 4242
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
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow traffic to postgresdb"
  }
}
