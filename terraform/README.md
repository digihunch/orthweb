## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.12.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

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
| [random_id.randsuffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [local_file.pubkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_provider_access_key"></a> [aws\_provider\_access\_key](#input\_aws\_provider\_access\_key) | n/a | `string` | `null` | no |
| <a name="input_aws_provider_secret_key"></a> [aws\_provider\_secret\_key](#input\_aws\_provider\_secret\_key) | n/a | `string` | `null` | no |
| <a name="input_local_pubkey_file"></a> [local\_pubkey\_file](#input\_local\_pubkey\_file) | n/a | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_tag_suffix"></a> [tag\_suffix](#input\_tag\_suffix) | n/a | `string` | `"orthweb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dbinfo"></a> [dbinfo](#output\_dbinfo) | n/a |
| <a name="output_host1info"></a> [host1info](#output\_host1info) | n/a |
| <a name="output_host2info"></a> [host2info](#output\_host2info) | n/a |
| <a name="output_s3bucket"></a> [s3bucket](#output\_s3bucket) | n/a |
