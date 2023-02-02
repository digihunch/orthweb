## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | ./modules/role | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_secret"></a> [secret](#module\_secret) | ./modules/secret | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_DeploymentOptions"></a> [DeploymentOptions](#input\_DeploymentOptions) | Deployment Options | `map(any)` | <pre>{<br>  "EnvoyImg": "envoyproxy/envoy:v1.25.0",<br>  "InstanceType": "t3.medium",<br>  "OrthancImg": "osimis/orthanc:22.12.2"<br>}</pre> | no |
| <a name="input_Tags"></a> [Tags](#input\_Tags) | Tags for every resource. | `map(any)` | <pre>{<br>  "Environment": "Dev",<br>  "Owner": "my@email.com"<br>}</pre> | no |
| <a name="input_pubkey_data"></a> [pubkey\_data](#input\_pubkey\_data) | n/a | `string` | `null` | no |
| <a name="input_pubkey_path"></a> [pubkey\_path](#input\_pubkey\_path) | n/a | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | n/a |
| <a name="output_host_info"></a> [host\_info](#output\_host\_info) | n/a |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | n/a |
| <a name="output_site_address"></a> [site\_address](#output\_site\_address) | n/a |
