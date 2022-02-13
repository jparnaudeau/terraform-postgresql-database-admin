#!/usr/bin/env python3

import sys
import traceback
import boto3
import os
from botocore.config import Config
import subprocess
import shlex


###########################
# MAIN
###########################
if __name__ == '__main__':

    try:
        
        # Retrieve environment variables
        region           = os.getenv('REGION')
        refresh_password = os.getenv('REFRESH_PASSWORD')
        rds_name         = os.getenv('RDS_NAME')
        database_user    = os.getenv('DBUSER')
        
        if refresh_password == "true":

            my_config = Config(
                                region_name = region,
                                # signature_version = 'v4',
                                # retries = {
                                #     'max_attempts': 10,
                                #     'mode': 'standard'
                                # }
                            )
            client = boto3.client('secretsmanager',config=my_config)

            # generate a random password
            response = client.get_random_password(
                                                    PasswordLength=32,
                                                    ExcludeNumbers=False,
                                                    ExcludePunctuation=True,
                                                    ExcludeUppercase=False,
                                                    ExcludeLowercase=False,
                                                    IncludeSpace=False,
                                                    RequireEachIncludedType=True
                                                )
            secret_value = response['RandomPassword']

            # retrieve secret-id
            secret_name = "secret-kv-{rdsName}-{userName}".format(rdsName=rds_name,userName=database_user)
            response = client.list_secrets(Filters=[
                                                {
                                                    'Key': 'name',
                                                    'Values': [
                                                        secret_name,
                                                    ]
                                                },
                                            ]
                                        )

            secret_id = response['SecretList'][0]['ARN']
            
            # update password in database : psql -c "ALTER USER $DBUSER WITH PASSWORD '$USERPWD'"
            postgresql_ddl = shlex.split("psql -c \"ALTER USER {userName} WITH PASSWORD '{secretValue}'\"".format(userName=database_user,secretValue=secret_value))
            process = subprocess.Popen(postgresql_ddl,
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE,
                     universal_newlines=True)
            while True:
                output = process.stdout.readline()
                print(output.strip())
                # Do something else
                return_code = process.poll()
                if return_code is not None:
                    print('RETURN CODE', return_code)
                    # Process has finished, read rest of the output 
                    for output in process.stdout.readlines():
                        print(output.strip())
                    break
                else:
            
                    # alter secret value
                    response = client.put_secret_value(SecretId=secret_id,
                                                    SecretString=secret_value,
                                                    )
                    
                    print("Succesfully alter secret {}".format(secret_name))
                    break

    except Exception as err:
        print("Exception during processing: {0}".format(err))
        traceback.print_exc()
        