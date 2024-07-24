## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.59.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

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
| <a name="input_CommonTags"></a> [CommonTags](#input\_CommonTags) | Tags for every resource. | `map(any)` | <pre>{<br>  "Environment": "Dev",<br>  "Owner": "my@digihunch.com"<br>}</pre> | no |
| <a name="input_DeploymentOptions"></a> [DeploymentOptions](#input\_DeploymentOptions) | Deployment Options | `map(any)` | <pre>{<br>  "EnvoyImg": "envoyproxy/envoy:v1.31.0",<br>  "InstanceType": "t3.medium",<br>  "OrthancImg": "orthancteam/orthanc:24.7.3"<br>}</pre> | no |
| <a name="input_pubkey_data"></a> [pubkey\_data](#input\_pubkey\_data) | n/a | `string` | `null` | no |
| <a name="input_pubkey_path"></a> [pubkey\_path](#input\_pubkey\_path) | n/a | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_scu_cidr_block"></a> [scu\_cidr\_block](#input\_scu\_cidr\_block) | n/a | `string` | `"0.0.0.0/0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | n/a |
| <a name="output_host_info"></a> [host\_info](#output\_host\_info) | n/a |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | n/a |
| <a name="output_site_address"></a> [site\_address](#output\_site\_address) | n/a |
