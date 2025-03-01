## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_client_vpn"></a> [client\_vpn](#module\_client\_vpn) | ./modules/client-vpn | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a |
| <a name="module_key"></a> [key](#module\_key) | ./modules/key | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Deployment Options for app configuration:<br/> `ConfigRepo` Git Repository for app configuration.<br/> `SiteName` The Site URL<br/> `InitCommand` The command to execute from the config directory<br/> `EnableCWLog` Enable sending Docker daemon log to Cloud Watch.<br/> `CWLogRetention` Retention for Log Group | <pre>object({<br/>    ConfigRepo     = string<br/>    SiteName       = string<br/>    InitCommand    = string<br/>    EnableCWLog    = bool<br/>    CWLogRetention = number<br/>  })</pre> | <pre>{<br/>  "CWLogRetention": 3,<br/>  "ConfigRepo": "https://github.com/digihunchinc/orthanc-config.git",<br/>  "EnableCWLog": true,<br/>  "InitCommand": "pwd && echo Custom Init Command (e.g. make aws)",<br/>  "SiteName": null<br/>}</pre> | no |
| <a name="input_ec2_config"></a> [ec2\_config](#input\_ec2\_config) | Configuration Options for EC2 instances | `map(string)` | <pre>{<br/>  "InstanceType": "t3.medium",<br/>  "PublicKeyData": null,<br/>  "PublicKeyPath": "~/.ssh/id_rsa.pub"<br/>}</pre> | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Networking Configuration<br/> `vpn_client_cidr` set to a non-conflicting CIDR of at least /22 to configure client VPN. Otherwise leave blank or null to not configure client VPN. | <pre>object({<br/>    vpc_cidr              = string<br/>    dcm_cli_cidrs         = list(string)<br/>    web_cli_cidrs         = list(string)<br/>    az_count              = number<br/>    public_subnet_pfxlen  = number<br/>    private_subnet_pfxlen = number<br/>    interface_endpoints   = list(string)<br/>    vpn_client_cidr       = string<br/>    vpn_cert_cn_suffix    = string<br/>    vpn_cert_valid_days   = number<br/>  })</pre> | <pre>{<br/>  "az_count": 2,<br/>  "dcm_cli_cidrs": [<br/>    "0.0.0.0/0"<br/>  ],<br/>  "interface_endpoints": [],<br/>  "private_subnet_pfxlen": 22,<br/>  "public_subnet_pfxlen": 24,<br/>  "vpc_cidr": "172.17.0.0/16",<br/>  "vpn_cert_cn_suffix": "vpn.digihunch.com",<br/>  "vpn_cert_valid_days": 3650,<br/>  "vpn_client_cidr": "",<br/>  "web_cli_cidrs": [<br/>    "0.0.0.0/0"<br/>  ]<br/>}</pre> | no |
| <a name="input_provider_tags"></a> [provider\_tags](#input\_provider\_tags) | Tags to apply for every resource by default | `map(string)` | <pre>{<br/>  "environment": "dev",<br/>  "owner": "info@digihunch.com"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | Database endpiont (port 5432 only accessible privately from EC2 Instance) |
| <a name="output_host_info"></a> [host\_info](#output\_host\_info) | Instance IDs and Public IPs of EC2 instances |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | S3 bucket name for data storage |
| <a name="output_server_dns"></a> [server\_dns](#output\_server\_dns) | DNS names of EC2 instances |
