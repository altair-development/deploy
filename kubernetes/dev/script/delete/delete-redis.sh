#!/bin/bash

echo "/*** delete redis **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../redis >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret redis-access-creds **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n redis-dev redis-access-creds >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace redis-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace redis-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

file_system_id=$(aws efs describe-file-systems --creation-token "altair-redis-shared" --query "FileSystems[*].FileSystemId" --output text)

mount_targets=($(aws efs describe-mount-targets --file-system-id $file_system_id --query "MountTargets[*].MountTargetId" --output text))

for M in "${mount_targets[@]}";
do
  echo "/*** delete mount-target. mount-target-id: $M **/" >> $LOGDIRNAME/$LOGFILENAME
  aws efs delete-mount-target --mount-target-id $M >> $LOGDIRNAME/$LOGFILENAME 2>&1
  if [ $? != 0 ]; then error ;fi
done

while [ "" != "$(aws efs describe-mount-targets --file-system-id $file_system_id --output text)" ]
do
  echo "waiting for mount target to be permanently deleted" >> $LOGDIRNAME/$LOGFILENAME 2>&1
  sleep 5
done;

echo "/*** delete file-system. file-system-id: $file_system_id **/" >> $LOGDIRNAME/$LOGFILENAME
aws efs delete-file-system --file-system-id $file_system_id >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

security_group_id=$(aws ec2 describe-security-groups --filter Name=group-name,Values=altair-redis-efs-dev --query 'SecurityGroups[*].[GroupId]' --output text)

echo "/*** delete-security-group. security-group-id: $security_group_id **/" >> $LOGDIRNAME/$LOGFILENAME
aws ec2 delete-security-group --group-id $security_group_id >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete public-ecr-driver **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../public-ecr-driver.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete iamserviceaccount --region $REGION --name efs-csi-controller-sa --namespace kube-system --cluster node-altair-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
