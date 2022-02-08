#------------ vpc -----------------#

output "vpc_id" {
  value       = data.aws_vpc.selected_vpc.id
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = data.aws_vpc.selected_vpc.cidr_block
  description = "The CIDR block of the VPC"
}

output "vpc_name" {
  value       = var.vpc_name
  description = "The name of the VPC specified as locals and infered from environment argument to this module"
}

#------------ AZs -----------------#

output "availability_zones" {
  value       = data.aws_availability_zones.azs.names
  description = "The Availability zone in the region this VPC span on"
}

#------------ Public Subnets -------------#

output "public_subnet_ids" {
  value       = tolist(values(zipmap(data.aws_subnet.public_subnets.*.availability_zone, data.aws_subnet.public_subnets.*.id)))
  description = "The IDs list of public subnets"
}

output "public_subnet_cidr" {
  value       = tolist(values(zipmap(data.aws_subnet.public_subnets.*.availability_zone, data.aws_subnet.public_subnets.*.cidr_block)))
  description = "The CIDR_BLOCK list of public subnets"
}

output "public_subnet_ids_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.public_subnets) :
    subnets.availability_zone => subnets.id
  }
  description = "The IDs list of public subnets classified by availibility zone names"
}

output "public_subnet_cidrs_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.public_subnets) :
    subnets.availability_zone => subnets.cidr_block
  }
  description = "The CIDR_BLOCK list of public subnets"
}

output "public_subnet_a_id" {
  value       = values(zipmap(data.aws_subnet.public_subnets.*.availability_zone, data.aws_subnet.public_subnets.*.id))[0]
  description = "The ID of public subnets-a (availibility zone A)"
}

output "public_subnet_b_id" {
  value       = values(zipmap(data.aws_subnet.public_subnets.*.availability_zone, data.aws_subnet.public_subnets.*.id))[1]
  description = "The ID of public subnets-b (availibility zone B)"
}

output "public_subnet_c_id" {
  value       = values(zipmap(data.aws_subnet.public_subnets.*.availability_zone, data.aws_subnet.public_subnets.*.id))[2]
  description = "The ID of public subnets-c (availibility zone C)"
}

#---------- Private Subnets --------------#

output "private_subnet_ids" {
  value       = tolist(values(zipmap(data.aws_subnet.private_subnets.*.availability_zone, data.aws_subnet.private_subnets.*.id)))
  description = "The IDs list of private subnets"
}

output "private_subnet_cidr" {
  value       = tolist(values(zipmap(data.aws_subnet.private_subnets.*.availability_zone, data.aws_subnet.private_subnets.*.cidr_block)))
  description = "The CIDR_BLOCK list of private subnets"
}

output "private_subnet_ids_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.private_subnets) :
    subnets.availability_zone => subnets.id
  }
  description = "The IDs list of private subnets classified by availibility zone names"
}

output "private_subnet_cidrs_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.private_subnets) :
    subnets.availability_zone => subnets.cidr_block
  }
  description = "The CIDR_BLOCK list of private subnets"
}

output "private_subnet_a_id" {
  value       = values(zipmap(data.aws_subnet.private_subnets.*.availability_zone, data.aws_subnet.private_subnets.*.id))[0]
  description = "The ID of private subnets-a (availibility zone A)"
}

output "private_subnet_b_id" {
  value       = values(zipmap(data.aws_subnet.private_subnets.*.availability_zone, data.aws_subnet.private_subnets.*.id))[1]
  description = "The ID of private subnets-b (availibility zone B)"
}

output "private_subnet_c_id" {
  value       = values(zipmap(data.aws_subnet.private_subnets.*.availability_zone, data.aws_subnet.private_subnets.*.id))[2]
  description = "The ID of private subnets-c (availibility zone C)"
}

#------------ Database Subnets -------------#

output "database_subnet_ids" {
  value       = tolist(values(zipmap(data.aws_subnet.database_subnets.*.availability_zone, data.aws_subnet.database_subnets.*.id)))
  description = "The IDs list of database subnets"
}

output "database_subnet_cidr" {
  value       = tolist(values(zipmap(data.aws_subnet.database_subnets.*.availability_zone, data.aws_subnet.database_subnets.*.cidr_block)))
  description = "The CIDR_BLOCK list of database subnets"
}

output "database_subnet_ids_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.database_subnets) :
    subnets.availability_zone => subnets.id
  }
  description = "The IDs list of database subnets classified by availibility zone names"
}

output "database_subnet_cidrs_by_azs_names" {
  value = { for subnets in toset(data.aws_subnet.database_subnets) :
    subnets.availability_zone => subnets.cidr_block
  }
  description = "The CIDR_BLOCK list of database subnets"
}

output "database_subnet_a_id" {
  value       = try(values(zipmap(data.aws_subnet.database_subnets.*.availability_zone, data.aws_subnet.database_subnets.*.id))[0], null)
  description = "The ID of database subnets-a (availibility zone A)"
}

output "database_subnet_b_id" {
  value       = try(values(zipmap(data.aws_subnet.database_subnets.*.availability_zone, data.aws_subnet.database_subnets.*.id))[1], null)
  description = "The ID of database subnets-b (availibility zone B)"
}

output "database_subnet_c_id" {
  value       = try(values(zipmap(data.aws_subnet.database_subnets.*.availability_zone, data.aws_subnet.database_subnets.*.id))[2], null)
  description = "The ID of database subnets-c (availibility zone C)"
}

#------------ Database Infos -------------#
output "database_identifier" {
  value       = try(data.aws_db_instance.database.*.db_instance_identifier[0], "")
  description = "The Identifier of the RDS Instance"
}

output "database_arn" {
  value       = try(data.aws_db_instance.database.*.db_instance_arn[0], "")
  description = "The ARN of the RDS Instance"
}