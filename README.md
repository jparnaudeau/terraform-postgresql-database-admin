# terraform-postgresql-database-admin

## Introduction

Terraform is a great tool to automate "everything" in modern IT. Based on my own experience, i will propose you an abstraction for the management "inside a database" : the management of users and their permissions in a postgresql database. 

This module provides a way to manage securly and properly, the objects, inside a postgresql database. Based on best practices, describe in this blog : 

https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/

Moreover, for a database deployed through the AWS Managed Service "RDS", this module also provides a way to deploy an audit system allowing to trace all the requests made, by whom, at what time and from which IP address.

The module is divided into 2 sub-modules and several examples that illustrates different aspects of this problematic.

* The creation of the database with the roles and the permissions associated with (named grant inside postgresql).
* The creation of the user. For security perspectives, user inherits permissions from role. A user should have an expiration date for his password.

## Diagram

The diagram below illustrate what we neeed to do : 

![db-relations](schemas/Diagram-Relations.png)

|Actor|Remarks|
|------|------|
|The user `postgres` or the `super-user`|This user should not be used in daily tasks. Instead, create an admin role on which you delegate high level permissions.|
|Application admin Role|This role will be the owner of the database and all objects inside the database. It can create database,tables inside database and roles.|
|ReadOnly Role|The role with grants that allowing select on tables.|
|Write Role|The role with grants that allowing select/insert/update/delete on tables.|
|The user `application reporting`| This user is used inside the reporting application.|
|The user `application backend`| This user is used inside the backend application. |

Notes : 

* Roles are independent from the database and schema. But we advice to create the 3 roles (admin,readonly,write) for each database and do not shared roles accross databases. That why, in the examples, we prefixe the name of the role by `app`, a trigram that can easily differentiate role in real usecases. If you need a user with permissions on differents databases, a user can inherits permissions from several roles.
* We create 3 roles (admin,write,readonly) but you can be more granular. By example, splitting the role write into several write roles, allowing the permissions insert/update/delete only on specific tables. the security pattern `Least privilege` can be applied at this level.

## schema public vs custom schema

### Working in the public schema

When a new database is created, PostgreSQL by default creates a schema named public and grants access on this schema to a backend role named public. All new users and roles are by default granted this public role, and therefore can create objects in the public schema.

PostgreSQL uses a concept of a search path. The search path is a list of schema names that PostgreSQL checks when you don’t use a qualified name of the database object. For example, when you select from a table named `mytable`, PostgreSQL looks for this table in the schemas listed in the search path. It chooses the first match it finds. By default, the search path contains the following schemas:

```
postgres=# show search_path;
   search_path   
-----------------
 "$user", public
(1 row)
```

The first name `$user` resolves to the name of the currently logged in user. By default, no schema with the same name as the user name exists. So the public schema becomes the default schema whenever an unqualified object name is used. Because of this, when a user tries to create a new table without specifying the schema name, the table gets created in the public schema. As mentioned earlier, by default, all users have access to create objects in the public schema, and therefore the table is created successfully.

This becomes a problem if you are trying to create a read-only user. Even if you restrict all privileges, the permissions inherited via the public role allow the user to create objects in the public schema.

To fix this, the default create permission on the public schema from the public role is revoked by default. It's managed by the variable **revoke_create_public** that is `true` by default in the module `create-database`.

### Working in a custom schema

Working with a custom schema is available but keep in mind that :

* you need to set the field **search_path** in each of the role. If you do not do that, you need to prefix each of your object with the name of the schema.

## It's not a bug !

If you create tables, apply this module by creating roles and permissions, with by example, the "write" permissions (insert/update/delete) on the tables, it works.

After the apply, if you create a new table, and try to insert lines into this table, you will have an error `Permission Denied`. It's not a bug. Because, the permissions put in the previous step are not retro-active. You need to re-execute the terraform apply to propagate permisisons (the write permissions) on the new table. 

## Modules Description


### create-database

This sub-module is in charge to create : 

* `postgresql database` : In some case, you need to create the database first.


* `postgresql role` : following best practices, we will create `role` in a first step. Those roles will handle grants (=permissions).


* `postgresql grant` : the list of grants that will be associated to the role.

This module uses a terraform object structure : Check the `simple-database` usecase to have a complete example.

you could find all Inputs & outputs of this submodule here : [docs](./create-database/DOC.md)


### create-users & Password Management

This sub-module is in charge to create : 

* `postgresql role` : a user is a role that inherits permissions from roles and have the option 'login' = true. A user can have an expiration date. It's a good practice to expire password for human users.

* Regarding `password management` inside a terraform module, it could be complex to manage properly passwords inside a generic module. You can refer to this excellent post to manage securly your passwords : https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1. 
* To provide a way to manage at posteriori the password of users created by the module, a system of `postprocessing playbook` is available to set the password securely. Why securely ? because it use a `terraform null_resource` to perform the update of the password in the database and to store the password in a safe place of your choice.


check the `create-users-on-existent-database` or `all-in-one` usecases to have complete examples.

you could find all Inputs & outputs of this submodule here : [docs](./create-users/DOC.md)


### lambda-stream-audit

TO COMPLETE

[docs](./lambda-stream-audit/DOC.md)


## Usecases

|Example|UseCase|
|-------|--------|
|[simple-database](./example/simple-database/README.md)|Demonstration How to create Database, Roles, and Grants objects.|
|[create-users-on-existent-database](./example/create-users-on-existent-database/README.md)|From an existent database, you can create several users. This usecase use a trivial postprocessing playbook for example. **DO NOT USE THIS PLAYBOOK IN PRODUCTION, IT's NOT SAFE.**|
|[all-in-one](./example/all-in-one/README.md)|Demonstration How to create Database, Roles, Users in one phase. This usecase use a postprocessing playbook that generate passwords, set password for each users, and store the password in the parameterStore into an AWS Account.|
|[full-rds-example](./example/full-rds-example/README.md)|Demonstration for other features covered by the module : Demonstrate an another postprocessing playbook that generate passwords into AWS SecretsManager, deploy the `pgaudit` extension for real-time monitoring, and deploy lambda to stream the audit logs.|


### Prerequirements

Those modules uses the excellent [postgresql provider](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs). for each usecase, you need to have : 

* the network connectivity to your database (by example, if you launch your terraform scripts from a gitlab-ci runner, your runners must reach the database)
* the credentials of a user with the required permissions to connect on a postgresql instance, to create database etc ... Often, we use postgres user for the postgresql provider, and a custom admin user for creating database and other objects. For the password, to avoid passing in clear text the password used by the postgresql provider, use the native postgresql mechanism by setting an environment variable **PGPASSWORD**.

### Tests environment

You can find a docker-compose file to start locally a postgresql (version 13.4) database and set the password for postgres user. Use the command `docker-compose -f docker-compose.yml up -d`.  


## Inputs & outputs



### create-database



### create-users
