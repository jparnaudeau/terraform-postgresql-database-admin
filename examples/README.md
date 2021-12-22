## Examples

|Example|UseCase|
|-------|--------|
|[simple-database](./simple-database/README.md)|Demonstration How to create Database, Roles, and Grants objects.|
|[create-users-on-existent-database](./create-users-on-existent-database/README.md)|From an existent database, you can create several users. This usecase use a trivial postprocessing playbook for example. **DO NOT USE THIS PLAYBOOK IN PRODUCTION, IT's NOT SAFE.**|
|[all-in-one](./all-in-one/README.md)|Demonstration How to create Database, Roles, Users in one phase. This usecase use a postprocessing playbook that generate passwords, set password for each users, and store the password in the parameterStore into an AWS Account.|
|[full-rds-example](./full-rds-example/README.md)|Demonstration for other features covered by the module : Demonstrate an another postprocessing playbook that generate passwords into AWS SecretsManager, deploy the `pgaudit` extension for real-time monitoring, and deploy lambda to stream the audit logs.|

