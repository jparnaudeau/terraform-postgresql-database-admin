#!/bin/bash

# generate a random password
USERPWD=$(openssl rand -base64 16 |tr -d '[;+%$!/]');

# generate the parameterStore path
USER_PWD_PATH="/${ENVIRONMENT}/${PGDATABASE}/${DBUSER}_password"

# Alter user inside postgresql database
psql -c "ALTER USER $DBUSER WITH PASSWORD '$USERPWD'";

# Alter Secret Storage
aws ssm put-parameter --name $USER_PWD_PATH --type SecureString --overwrite --value $USERPWD --region $REGION;

exit 0
