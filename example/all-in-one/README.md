## all-in-one



## Allowed UseCase Matrix 

Based on this component, this is the matrix providing permissions for different users defined in this example : 

|DDB User|Login on database|Create/Drop Database|Create/Drop Schema|Create/Drop Role|Create/Drop Table|Insert/Delete items in Table|Select on table|
|--------|-----------------|--------------------|------------------|----------------|-----------------|----------------------------|---------------|
|demo_root|OK|OK|OK|OK|OK|OK|OK|
|sa_admin|OK|OK|OK|OK (By default can't create role)|OK|OK|OK|
|sa_myapp|OK|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK|OK|
|pa009093|OK|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK (Permission denied)|OK|

Note : you can allow the user `sa_admin` to create role, by using the field **createrole** in the **db_users** declaration.
