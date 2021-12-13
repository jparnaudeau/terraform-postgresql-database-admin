import boto3
import os


def handler(event, context):
    # Client init 
    rds = boto3.client('rds')
    
    # List of RDS Instances
    rds_instance_names = os.getenv('RDS_INSTANCE_NAMES')
    
    for instance_name in rds_instance_names.split(','):
        
        # Name log file
        temp_logfile = '/tmp/rds_'+instance_name+'.log'   
        
        # Get last log and save it to temp file
        saveLastLog(temp_logfile,rds,instance_name)
        
        # Check and return audit data
        if findAuditEvents(temp_logfile):
            print('Found Audit events for instance : '+ instance_name +'..')
            array = findAuditEvents(temp_logfile)
            output = "\n".join(str(x) for x in array)
            os.remove(temp_logfile)
            print(output)
        else: 
            print("No audit data found for "+ instance_name +", skipping...")
            


# Save last log file
def saveLastLog(temp_logfile,rds,instance_name):
    # Log file 
    get_log_file = rds.describe_db_log_files(
        DBInstanceIdentifier=instance_name
    )
    
    # Get last log and save it to file
    log_file = get_log_file['DescribeDBLogFiles'][-1]['LogFileName']
    with open(temp_logfile, 'w') as f:
        token = '0'
        get_log_data = rds.download_db_log_file_portion(
            DBInstanceIdentifier=instance_name,
            LogFileName=log_file,
            Marker=token
        )
        while get_log_data['AdditionalDataPending']:
            f.write(get_log_data['LogFileData'])
            token = get_log_data['Marker']
            get_log_data = rds.download_db_log_file_portion(
                DBInstanceIdentifier=instance_name,
                LogFileName=log_file,
                Marker=token
            )
        f.write(get_log_data['LogFileData'])
    f.close()


# Find Audit data in saved logfile 
def findAuditEvents(temp_logfile): 
    array = []
    with open(temp_logfile, 'r') as f:
        for line in f:
            if 'AUDIT' in line:
                array.append(line)
    f.close()
    if array:
        return array
    else:
        return False