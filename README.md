# terraform_aws_simple_infra
A simple terraform config to spin out an EC2 instance.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.local_vm_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.this_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.this_keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.this_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS profile to use for running the code | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | `"eu-west-2"` | no |
| <a name="input_ec2_instance_ami"></a> [ec2\_instance\_ami](#input\_ec2\_instance\_ami) | EC2 Instance AMI | `string` | `"ami-024294779773cf91a"` | no |
| <a name="input_ec2_instance_name"></a> [ec2\_instance\_name](#input\_ec2\_instance\_name) | Name of the EC2 instance | `string` | `"myec2_instance"` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 Instance Type | `string` | `"t3.nano"` | no |
| <a name="input_igw_name"></a> [igw\_name](#input\_igw\_name) | Internet Gateway Name | `string` | `"main-igw"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Subnet CIDR values | `string` | `"10.0.0.0/24"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnet Name | `string` | `"public_subnet"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR values | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC Name | `string` | `"main-vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_details"></a> [ec2\_instance\_details](#output\_ec2\_instance\_details) | n/a |
| <a name="output_subnet_details"></a> [subnet\_details](#output\_subnet\_details) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Outputs for the resource created. |
