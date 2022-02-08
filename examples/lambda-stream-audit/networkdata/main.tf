
#--------- VPC -----------------------#

data "aws_vpc" "selected_vpc" {

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

#--------- AZs -----------------------#
data "aws_availability_zones" "azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


#-------- Public Subnets -------------#

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = data.aws_vpc.selected_vpc.id

  filter {
    name   = "tag:Name"
    values = var.public_subnet_names
  }

  # filter {
  #   name   = "tag:SubnetType"
  #   values = ["public"] # insert values here
  # }
}

data "aws_subnet" "public_subnets" {
  count = length(data.aws_subnet_ids.public_subnet_ids.ids)
  id    = tolist(data.aws_subnet_ids.public_subnet_ids.ids)[count.index]
}

#-------- Private Subnets ------------#

data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id = data.aws_vpc.selected_vpc.id

  filter {
    name   = "tag:Name"
    values = var.private_subnet_names
  }

  # filter {
  #   name   = "tag:SubnetType"
  #   values = ["private"] # insert values here
  # }
}

data "aws_subnet" "private_subnets" {
  count = length(data.aws_subnet_ids.private_subnet_ids.ids)
  id    = tolist(data.aws_subnet_ids.private_subnet_ids.ids)[count.index]
}

#-------- Database Subnets ------------#

data "aws_subnet_ids" "database_subnet_ids" {
  vpc_id = data.aws_vpc.selected_vpc.id

  filter {
    name   = "tag:Name"
    values = var.database_subnet_names
  }

  # filter {
  #   name   = "tag:SubnetType"
  #   values = ["database"]
  # }
}


data "aws_subnet" "database_subnets" {
  count = length(data.aws_subnet_ids.database_subnet_ids.ids)
  id    = tolist(data.aws_subnet_ids.database_subnet_ids.ids)[count.index]
}

# ---------------------- Additonl Resources ---------------------- #
data "aws_db_instance" "database" {
  count                  = contains(keys(var.resources), "database") ? 1 : 0
  db_instance_identifier = var.resources["database"]
}
