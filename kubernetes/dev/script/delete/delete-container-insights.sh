#!/bin/bash

FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'

echo "/*** delete cwagent-fluent-bit-quickstart **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${CLUSTER_NAME}'/;s/{{region_name}}/'${REGION}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl delete -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete cloudwatch-agent iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete iamserviceaccount --region $REGION --name cloudwatch-agent --namespace amazon-cloudwatch --cluster $CLUSTER_NAME >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete cloudwatch-agent iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete iamserviceaccount --region $REGION --name fluent-bit --namespace amazon-cloudwatch --cluster $CLUSTER_NAME >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace amazon-cloudwatch **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace amazon-cloudwatch >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi