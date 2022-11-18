## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.40.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2.0 |

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
| <a name="module_secretmanager"></a> [secretmanager](#module\_secretmanager) | ./modules/secmgr | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_DockerImages"></a> [DockerImages](#input\_DockerImages) | Docker Images | `map(any)` | <pre>{<br>  "EnvoyImg": "envoyproxy/envoy:v1.21-latest",<br>  "OrthancImg": "osimis/orthanc:22.11.3"<br>}</pre> | no |
| <a name="input_Tags"></a> [Tags](#input\_Tags) | Tags for every resource. | `map(any)` | <pre>{<br>  "Environment": "Dev",<br>  "Owner": "my@email.com"<br>}</pre> | no |
| <a name="input_cli_cidr_block"></a> [cli\_cidr\_block](#input\_cli\_cidr\_block) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_pubkey_data"></a> [pubkey\_data](#input\_pubkey\_data) | n/a | `string` | `null` | no |
| <a name="input_pubkey_path"></a> [pubkey\_path](#input\_pubkey\_path) | n/a | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dbinfo"></a> [dbinfo](#output\_dbinfo) | n/a |
| <a name="output_hostinfo"></a> [hostinfo](#output\_hostinfo) | n/a |
| <a name="output_s3bucket"></a> [s3bucket](#output\_s3bucket) | n/a |
