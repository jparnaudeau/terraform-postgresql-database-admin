########################################
# define variables for postgresql database connectivity
########################################
variable "dbport" {
  type        = number
  default     = 5432
  description = "The database port"
}

variable "sslmode" {
  type        = string
  description = "Set the priority for an SSL connection to the server. Valid values are [disable,require,verify-ca,verify-full]"
  default     = "require"
}

variable "connect_timeout" {
  type        = number
  description = "Maximum wait for connection, in seconds. The default is 180s. Zero or not specified means wait indefinitely."
  default     = 180
}

variable "superuser" {
  type        = bool
  description = "Should be set to false if the user to connect is not a PostgreSQL superuser"
  default     = false
}

variable "expected_version" {
  type        = string
  description = "Specify a hint to Terraform regarding the expected version that the provider will be talking with. This is a required hint in order for Terraform to talk with an ancient version of PostgreSQL. This parameter is expected to be a PostgreSQL Version or current. Once a connection has been established, Terraform will fingerprint the actual version. Default: 9.0.0"
  default     = "12.0.0"
}

########################################
# define variables for postgresql database creation
########################################
variable "inputs" {
  type        = any
  description = "The map containing all elements for creating objects inside database"
  default     = null
}

########################################
# define global variables tags, env, ...
########################################
variable "tags" {
  type        = map(string)
  description = "a map of string used to tag entries in AWS Secrets Manager"
  default     = {}
}

variable "environment" {
  type        = string
  description = "environment name"
  default     = "sta"
}

########################################
# define variables for vpc
########################################
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "list of public subnets range"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "list of private subnets range"
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "vpc_database_subnets" {
  type        = list(string)
  description = "list of database subnets range"
  default     = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
}

########################################
# define variables for rds
########################################
variable "region" {
  type        = string
  description = "AWS Region name"
  default     = "eu-west-3"
}

variable "rds_name" {
  type        = string
  description = "RDS Database Name"
  default     = "mydatabase"
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "List of allowed IP addresses"
  default     = []
}

variable "rds_major_engine_version" {
  type        = string
  description = "RDS Major Engine Version"
  default     = "13"
}

variable "rds_engine_version" {
  type        = string
  description = "RDS Engine Version"
  default     = "13.5"
}

variable "rds_family" {
  type        = string
  description = "RDS Family"
  default     = "postgres13"
}

variable "rds_instance_class" {
  type        = string
  description = "RDS Instance class"
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS Inital Allocated Storage"
  default     = 10
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "RDS Max Allocated Storage"
  default     = 20
}

variable "rds_storage_encrypted" {
  type        = bool
  description = "Enable encryption at rest"
  default     = true
}

variable "rds_superuser_name" {
  type        = string
  description = "The default super-user name"
  default     = "root"
}

variable "rds_root_password" {
  type        = string
  description = "Password for RDS super-user"
  sensitive   = true
}

variable "parameter_group_params" {
  type        = map(any)
  description = "custom parameter group instance params"
  default     = {}
}


########################################
# define variables for AWS SecretsManager
########################################
variable "recovery_window_in_days" {
  type        = number
  description = "delay in days during a secret can be recoverd"
  default     = 7
}

variable "refresh_passwords" {
  type        = list(string)
  description = "The list of users that we want refresh its password. Default '[all]'"
  default     = ["all"]
}

########################################
# define variables for ElasticSearch
########################################
variable "create_elasticsearch" {
  type        = bool
  description = "Enable or Not the creation of an elasticSearch to simulate a SOC Tool"
  default     = false
}

variable "es_instance_type" {
  type        = string
  description = "InstanceType for ElasticSearch Node"
  default     = "t3.small.elasticsearch"
}

variable "es_instance_count" {
  type        = number
  description = "Number of instances in the ElasticSearch Domain"
  default     = 1
}

variable "es_ebs_volume_size" {
  type        = number
  description = "EBS Size associated to each node in the ElasticSearch Domain"
  default     = 10
}
