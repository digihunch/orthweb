locals {
  vpncfg_filename = "vpn-config.ovpn"
}

data "aws_region" "this" {}

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "ca.${var.vpn_config.vpn_cert_cn_suffix}"
    organization = "VPN Certificate Organization"
  }

  is_ca_certificate     = true
  set_authority_key_id  = true
  set_subject_key_id    = true
  validity_period_hours = var.vpn_config.vpn_cert_valid_days

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
    common_name = "server.${var.vpn_config.vpn_cert_cn_suffix}"
  }

  dns_names = ["server.${var.vpn_config.vpn_cert_cn_suffix}"]
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name = "client.${var.vpn_config.vpn_cert_cn_suffix}"
  }

  dns_names = ["client.${var.vpn_config.vpn_cert_cn_suffix}"]
}

resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  set_subject_key_id    = true
  is_ca_certificate     = false
  validity_period_hours = var.vpn_config.vpn_cert_valid_days * 24

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

  validity_period_hours = var.vpn_config.vpn_cert_valid_days * 24

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
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "ImportedVPNServerCertificate"
  }
}

resource "aws_acm_certificate" "imported_vpn_client_cert" {
  private_key       = tls_private_key.client_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.client_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "ImportedVPNClientCertificate"
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "Client VPN Endpoint"
  server_certificate_arn = aws_acm_certificate.imported_vpn_server_cert.arn
  client_cidr_block      = var.vpn_config.vpn_client_cidr
  vpc_id                 = var.vpn_config.vpc_id
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
    Name = "ClientVPN-Endpoint"
  }
}

data "external" "vpn_config_base" {
  program    = ["bash", "-c", "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.client_vpn.id} --region ${data.aws_region.this.name} --output json"]
  depends_on = [aws_ec2_client_vpn_endpoint.client_vpn]
}

resource "local_file" "vpn_config" {
  depends_on = [aws_ec2_client_vpn_endpoint.client_vpn]
  filename   = "./out/${local.vpncfg_filename}"
  content = <<-EOT
${data.external.vpn_config_base.result.ClientConfiguration}

<cert>
${tls_locally_signed_cert.client_cert.cert_pem}
</cert>

<key>
${tls_private_key.client_key.private_key_pem_pkcs8}
</key>
EOT
}

# Upload the VPN config file to S3 bucket
resource "aws_s3_object" "vpc_config_file" {
  bucket      = var.s3_bucket_name
  key         = "config/${local.vpncfg_filename}"
  source      = "./out/${local.vpncfg_filename}"
  #source_hash = fileexists("./out/${local.vpncfg_filename}") ? filebase64sha256("./out/${local.vpncfg_filename}") : null

  depends_on = [resource.local_file.vpn_config]
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.vpn_config.vpc_cidr ## Where the client VPN can connect.
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet_association" {
  #for_each               = toset(var.vpn_config.private_subnet_ids)
  # for_each doesn't like values derived from resource attributes that cannot be determined until apply
  # therefore for_each would require targeted apply first. 
  count                  = length(var.vpn_config.private_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.vpn_config.private_subnet_ids[count.index]
}

resource "aws_security_group" "vpn_secgroup" {
  name        = "${var.resource_prefix}-vpn-secgroup"
  description = "Security group for VPN endpoint"
  vpc_id      = var.vpn_config.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow UDP traffic coming in through port 443"
  }

  tags = { Name = "${var.resource_prefix}-vpn-sg" }
}
