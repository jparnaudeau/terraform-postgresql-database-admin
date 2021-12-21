# simple-database

Terraform is a great tool to automate "everything" in modern IT. Based on my own experience, i will propose you an abstraction for the management "inside a database" : the management of users and their permissions in a postgresql database. 

This module provides a way to manage securly and properly, the objects, inside a postgresql database. Based on best practices, describe in this blog : 

https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/

Moreover, for a database deployed through the AWS Managed Service "RDS", this module also provides a way to deploy an audit system allowing to trace all the requests made, by whom, at what time and from which IP address.

The module is divided into 2 sub-modules and several examples that illustrates different aspects of this problematic.

* The creation of the database with the roles and the permissions associated with (named grant inside postgresql).
* The creation of the user. For security perspective, user inherits permissions from role. A user should have an expiration date for his password.



### :warning: Important note:

We highly recommand you using **explicitly a version tag of this module** instead of branch reference since the latter is changing frequently. (use **ref=v1.0.0**,  don't use **ref=master**) 