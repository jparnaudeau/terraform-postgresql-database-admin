#!/usr/bin/env python3

import boto3
import os
import re
import json

pattern = '(.+?) (.+?) (.+?):(.+?):(.+?):(.+?):(.+?):(.+?):(.+?)$'

def handler(event, context):
    # Client init 
    rds = boto3.client('rds')
    
    # Retrieve RDS Instances to watch
    rds_instances = os.getenv('RDS_INSTANCES',None)
    output_format = os.getenv('FORMAT','SIMPLE')
    
    if rds_instances:
        for instance_name in rds_instances.split(','):
            
            # Get last log and save it to temp file
            # saveLastLog(temp_logfile,rds,instance_name)
            
            # Get Audit Log file 
            db_logfiles = rds.describe_db_log_files(DBInstanceIdentifier=instance_name)
            
            if db_logfiles:
            
                # Get last log
                log_file = db_logfiles['DescribeDBLogFiles'][-1]['LogFileName']
                #print("Last Log To stream : {}".format(log_file))
                token = '0'
                log_data = rds.download_db_log_file_portion(
                    DBInstanceIdentifier=instance_name,
                    LogFileName=log_file,
                    Marker=token
                )
                
                # because it's just a portion of the last file, need to iterate on other portions if needed
                firstTime = True
                while firstTime or log_data['AdditionalDataPending']:
                    # print on stdout the audit logs
                    filterAuditLogs(log_data['LogFileData'],output_format)
                    firstTime = False

                    token = log_data['Marker']
                    log_data = rds.download_db_log_file_portion(
                        DBInstanceIdentifier=instance_name,
                        LogFileName=log_file,
                        Marker=token
                    )
                
                print("No more audit data found for "+ instance_name +", skipping...")
            
    else:
        print("Environment Variable 'RDS_INSTANCES' not found")
            


def filterAuditLogs(content,output_format):
    
    for line in content.splitlines():
        if "AUDIT" in line:
            if output_format == 'JSON':
                printJsonFromLine(line)
            else:
                print(line)
                
def printJsonFromLine(line):
    
    m = re.search(pattern, line)
    if m:
        
        # reassemble all chunks in a map
        jsonContent = {}
        jsonContent["timestamp"] = "{} {} {}".format(m.group(1),m.group(2),m.group(3))
        jsonContent["ipaddress"] = m.group(4)
        jsonContent["user"]      = m.group(5)
        pgAuditLogValues = m.group(9).split(",")
        # pattern is described here : https://github.com/pgaudit/pgaudit#format
        pgAuditLogInfos = [
            "AuditType",
            "StatementId",
            "SubStatementId",
            "Class",
            "Command",
            "ObjectType",
            "ObjectName",
            "Statement",
            "Parameter",
        ]

        for i in range(0,len(pgAuditLogInfos)):
            jsonContent[pgAuditLogInfos[i]] = pgAuditLogValues[i]
            
        print(json.dumps(jsonContent, indent=3))
        
    else:
        print(line)
    
###########################
# MAIN
###########################
if __name__ == '__main__':
    handler(None,None)
    