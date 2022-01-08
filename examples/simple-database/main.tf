module "initdb" {

  source  = "jparnaudeau/database-admin/postgresql//create-database"
  version = "1.0.6"


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

