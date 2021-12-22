module "initdb" {

  source = "../../create-database"
  #source = "git::https://github.com/jparnaudeau/terraform-postgresql-database-admin.git//create-database?ref=jpa/first-version"


  # set the provider
  providers = {
    postgresql = postgresql.pgadm
  }

  # targetted rds
  pgadmin_user = var.pgadmin_user
  dbhost       = var.dbhost
  dbport       = var.dbport

  # input parameters for creating database & objects inside database
  create_database = true
  inputs          = var.inputs
}

