#!/bin/bash


if [ "${REFRESH_PASSWORD}" == "true" ]
then

    echo $REFRESH_PASSWORD
    # generate a random password
    USERPWD=$(openssl rand -base64 16 |tr -d '[;+%$!/]');

    # Alter user inside postgresql database
    psql -c "ALTER USER $DBUSER WITH PASSWORD '$USERPWD'";

    # Alter Secret Storage
    #aws ssm put-parameter --name $USER_PWD_PATH --type SecureString --overwrite --value $USERPWD --key-id $KMS_KEY_ID --region $REGION;
    echo "{password: $USERPWD}" > ./$DBUSER.json 

fi

exit 0
