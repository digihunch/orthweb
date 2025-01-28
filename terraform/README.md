## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
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
| <a name="input_deployment_options"></a> [deployment\_options](#input\_deployment\_options) | Deployment Options for Orthac app configuration | `map(string)` | <pre>{<br/>  "ConfigRepo": "https://github.com/digihunchinc/orthanc-config.git",<br/>  "InitCommand": "pwd && echo Init",<br/>  "InstanceType": "t3.medium",<br/>  "SiteName": null<br/>}</pre> | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Networking Configuration | <pre>object({<br/>    vpc_cidr              = string<br/>    scu_cidr              = string<br/>    az_count              = number<br/>    public_subnet_pfxlen  = number<br/>    private_subnet_pfxlen = number<br/>  })</pre> | <pre>{<br/>  "az_count": 2,<br/>  "private_subnet_pfxlen": 22,<br/>  "public_subnet_pfxlen": 24,<br/>  "scu_cidr": "0.0.0.0/0",<br/>  "vpc_cidr": "172.17.0.0/16"<br/>}</pre> | no |
| <a name="input_provider_tags"></a> [provider\_tags](#input\_provider\_tags) | Tags to apply for every resource by default | `map(string)` | <pre>{<br/>  "environment": "dev",<br/>  "owner": "info@digihunch.com"<br/>}</pre> | no |
| <a name="input_pubkey_data"></a> [pubkey\_data](#input\_pubkey\_data) | Public key content for the EC2 instance to authorize. If the key isn't stored in a local file. | `string` | `null` | no |
| <a name="input_pubkey_path"></a> [pubkey\_path](#input\_pubkey\_path) | Path to file that stores the SSH public key for the EC2 instance to authorize. | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | n/a |
| <a name="output_host_info"></a> [host\_info](#output\_host\_info) | n/a |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | n/a |
| <a name="output_site_address"></a> [site\_address](#output\_site\_address) | n/a |
