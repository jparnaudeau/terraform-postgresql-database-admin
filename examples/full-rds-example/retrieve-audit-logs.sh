#!/bin/bash

export INSTANCE_IDENTIFIER=`terraform output|grep db_instance_id|awk -F '=' '{print $2}'|sed 's/^ *//g'|sed 's/"//g'`

LOGFILE=$(aws rds describe-db-log-files --db-instance-identifier ${INSTANCE_IDENTIFIER} --query 'DescribeDBLogFiles[-1].[LogFileName]' --output text)

aws rds download-db-log-file-portion \
--db-instance-identifier ${INSTANCE_IDENTIFIER} \
--starting-token 0 \
--log-file-name "${LOGFILE}" \
--output text | grep AUDIT
