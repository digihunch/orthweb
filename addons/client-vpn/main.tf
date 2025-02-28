data "aws_vpc" "main" {
  id = var.client_vpn_options.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.client_vpn_options.vpc_id]
  }
  tags = {
    Type = "Private"
  }
}

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "ca.${var.client_vpn_options.cert_domain_suffix}"
    organization = "VPN Organization"
  }

  is_ca_certificate     = true
  set_authority_key_id  = true
  set_subject_key_id    = true
  validity_period_hours = var.client_vpn_options.cert_validity_period_hours

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name = "server.${var.client_vpn_options.cert_domain_suffix}"
  }

  dns_names = ["server.${var.client_vpn_options.cert_domain_suffix}"]
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name = "client.${var.client_vpn_options.cert_domain_suffix}"
  }

  dns_names = ["client.${var.client_vpn_options.cert_domain_suffix}"]
}

resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  set_subject_key_id    = true
  is_ca_certificate     = false
  validity_period_hours = var.client_vpn_options.cert_validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem   = tls_cert_request.client_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = var.client_vpn_options.cert_validity_period_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "aws_acm_certificate" "imported_vpn_server_cert" {
  private_key       = tls_private_key.server_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.server_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem

  tags = {
    Name = "ImportedVPNServerCertificate"
  }
}

resource "aws_acm_certificate" "imported_vpn_client_cert" {
  private_key       = tls_private_key.client_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.client_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem

  tags = {
    Name = "ImportedVPNClientCertificate"
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "Client VPN"
  server_certificate_arn = aws_acm_certificate.imported_vpn_server_cert.arn
  client_cidr_block      = var.client_vpn_options.vpn_client_cidr
  vpc_id                 = var.client_vpn_options.vpc_id
  security_group_ids     = [aws_security_group.vpn_secgroup.id]
  split_tunnel           = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.imported_vpn_client_cert.arn
  }

  connection_log_options {
    enabled = false
  }
  tags = {
    Name = "ClientVPN"
  }
  provisioner "local-exec" {
    command = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${self.id} --output text > out/vpn-config.ovpn.part"
  }
}

resource "local_file" "vpn_config" {
  depends_on = [aws_ec2_client_vpn_endpoint.client_vpn]
  filename   = "out/vpn-config.ovpn"
  content    = <<-EOT
${file("out/vpn-config.ovpn.part")}

<cert>
${tls_locally_signed_cert.client_cert.cert_pem}
</cert>

<key>
${tls_private_key.client_key.private_key_pem_pkcs8}
</key>
EOT
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = data.aws_vpc.main.cidr_block ## Where the client VPN can connect.
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet_association" {
  for_each               = toset(data.aws_subnets.private.ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = each.value
}

resource "aws_security_group" "vpn_secgroup" {
  name        = "vpn-secgroup"
  description = "Security group for VPN endpoint"
  vpc_id      = var.client_vpn_options.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
