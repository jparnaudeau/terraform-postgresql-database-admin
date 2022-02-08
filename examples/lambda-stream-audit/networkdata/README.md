## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.azs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route_table.private_a_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_table.private_b_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_table.private_c_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_table.public_a_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_table.public_b_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_table.public_c_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_route_tables.private_rts_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_route_tables.public_rts_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_security_group.lambda_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_groups.lambda_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_subnet.database_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet_ids.database_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_subnet_ids.private_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_subnet_ids.public_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.selected_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [terraform_remote_state.transitgateway](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for which we want retrieve infos on network | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | `"eu-west-1"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | A list of resources value. possible resources value supported are : `lambda_default_sg` | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | The Availability zone in the region this VPC span on |
| <a name="output_database_subnet_a_id"></a> [database\_subnet\_a\_id](#output\_database\_subnet\_a\_id) | The ID of database subnets-a (availibility zone A) |
| <a name="output_database_subnet_b_id"></a> [database\_subnet\_b\_id](#output\_database\_subnet\_b\_id) | The ID of database subnets-b (availibility zone B) |
| <a name="output_database_subnet_c_id"></a> [database\_subnet\_c\_id](#output\_database\_subnet\_c\_id) | The ID of database subnets-c (availibility zone C) |
| <a name="output_database_subnet_cidr"></a> [database\_subnet\_cidr](#output\_database\_subnet\_cidr) | The CIDR\_BLOCK list of database subnets |
| <a name="output_database_subnet_cidrs_by_azs_names"></a> [database\_subnet\_cidrs\_by\_azs\_names](#output\_database\_subnet\_cidrs\_by\_azs\_names) | The CIDR\_BLOCK list of database subnets |
| <a name="output_database_subnet_ids"></a> [database\_subnet\_ids](#output\_database\_subnet\_ids) | The IDs list of database subnets |
| <a name="output_database_subnet_ids_by_azs_names"></a> [database\_subnet\_ids\_by\_azs\_names](#output\_database\_subnet\_ids\_by\_azs\_names) | The IDs list of database subnets classified by availibility zone names |
| <a name="output_lambda_default_sg_id"></a> [lambda\_default\_sg\_id](#output\_lambda\_default\_sg\_id) | The Default SecurityGroup Id to use with lambda |
| <a name="output_private_route_table_a_id"></a> [private\_route\_table\_a\_id](#output\_private\_route\_table\_a\_id) | The ID of private route table on availibility zone A |
| <a name="output_private_route_table_b_id"></a> [private\_route\_table\_b\_id](#output\_private\_route\_table\_b\_id) | The ID of private route table on availibility zone B |
| <a name="output_private_route_table_c_id"></a> [private\_route\_table\_c\_id](#output\_private\_route\_table\_c\_id) | The ID of private route table on availibility zone C |
| <a name="output_private_route_tables_ids"></a> [private\_route\_tables\_ids](#output\_private\_route\_tables\_ids) | A list of all private route tables ids |
| <a name="output_private_subnet_a_id"></a> [private\_subnet\_a\_id](#output\_private\_subnet\_a\_id) | The ID of private subnets-a (availibility zone A) |
| <a name="output_private_subnet_b_id"></a> [private\_subnet\_b\_id](#output\_private\_subnet\_b\_id) | The ID of private subnets-b (availibility zone B) |
| <a name="output_private_subnet_c_id"></a> [private\_subnet\_c\_id](#output\_private\_subnet\_c\_id) | The ID of private subnets-c (availibility zone C) |
| <a name="output_private_subnet_cidr"></a> [private\_subnet\_cidr](#output\_private\_subnet\_cidr) | The CIDR\_BLOCK list of private subnets |
| <a name="output_private_subnet_cidrs_by_azs_names"></a> [private\_subnet\_cidrs\_by\_azs\_names](#output\_private\_subnet\_cidrs\_by\_azs\_names) | The CIDR\_BLOCK list of private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The IDs list of private subnets |
| <a name="output_private_subnet_ids_by_azs_names"></a> [private\_subnet\_ids\_by\_azs\_names](#output\_private\_subnet\_ids\_by\_azs\_names) | The IDs list of private subnets classified by availibility zone names |
| <a name="output_public_route_table_a_id"></a> [public\_route\_table\_a\_id](#output\_public\_route\_table\_a\_id) | The ID of public route table availibility zone A |
| <a name="output_public_route_table_b_id"></a> [public\_route\_table\_b\_id](#output\_public\_route\_table\_b\_id) | The ID of public route table availibility zone B |
| <a name="output_public_route_table_c_id"></a> [public\_route\_table\_c\_id](#output\_public\_route\_table\_c\_id) | The ID of public route table availibility zone C |
| <a name="output_public_route_tables_ids"></a> [public\_route\_tables\_ids](#output\_public\_route\_tables\_ids) | A list of all public route tables ids |
| <a name="output_public_subnet_a_id"></a> [public\_subnet\_a\_id](#output\_public\_subnet\_a\_id) | The ID of public subnets-a (availibility zone A) |
| <a name="output_public_subnet_b_id"></a> [public\_subnet\_b\_id](#output\_public\_subnet\_b\_id) | The ID of public subnets-b (availibility zone B) |
| <a name="output_public_subnet_c_id"></a> [public\_subnet\_c\_id](#output\_public\_subnet\_c\_id) | The ID of public subnets-c (availibility zone C) |
| <a name="output_public_subnet_cidr"></a> [public\_subnet\_cidr](#output\_public\_subnet\_cidr) | The CIDR\_BLOCK list of public subnets |
| <a name="output_public_subnet_cidrs_by_azs_names"></a> [public\_subnet\_cidrs\_by\_azs\_names](#output\_public\_subnet\_cidrs\_by\_azs\_names) | The CIDR\_BLOCK list of public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs list of public subnets |
| <a name="output_public_subnet_ids_by_azs_names"></a> [public\_subnet\_ids\_by\_azs\_names](#output\_public\_subnet\_ids\_by\_azs\_names) | The IDs list of public subnets classified by availibility zone names |
| <a name="output_transitgateway_arn"></a> [transitgateway\_arn](#output\_transitgateway\_arn) | The ARN of the TransitGateway |
| <a name="output_transitgateway_id"></a> [transitgateway\_id](#output\_transitgateway\_id) | The ID of the TransitGateway |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC specified as locals and infered from environment argument to this module |
