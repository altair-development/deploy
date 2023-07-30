#!/bin/bash

echo "/*** deploy iam-oidc-provider **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl utils associate-iam-oidc-provider --region $REGION --cluster node-altair-dev --approve >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create efs iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create iamserviceaccount --name efs-csi-controller-sa --namespace kube-system --cluster node-altair-dev --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AmazonEKS_EFS_CSI_Driver_Policy --approve --override-existing-serviceaccounts --region $REGION >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply public-ecr-driver **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../public-ecr-driver.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

vpc_id=$(aws eks describe-cluster --name node-altair-dev --query "cluster.resourcesVpcConfig.vpcId" --output text) >> $LOGDIRNAME/$LOGFILENAME 2>&1

cidr_range=$(aws ec2 describe-vpcs --vpc-ids $vpc_id --query "Vpcs[].CidrBlock" --output text) >> $LOGDIRNAME/$LOGFILENAME 2>&1

echo "/*** create security-group. group-name: altair-redis-efs-dev **/" >> $LOGDIRNAME/$LOGFILENAME
security_group_id=$(aws ec2 create-security-group --group-name altair-redis-efs-dev --description "redis-dev security group for altair" --vpc-id $vpc_id --output text) >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create inbound rule **/" >> $LOGDIRNAME/$LOGFILENAME
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 2049 --cidr $cidr_range >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create efs-file-system **/" >> $LOGDIRNAME/$LOGFILENAME
file_system_id=$(aws efs create-file-system --region $REGION --creation-token "altair-redis-shared" --performance-mode generalPurpose --query 'FileSystemId' --output text)
if [ $? != 0 ]; then error ;fi

while [ available != $(aws efs describe-file-systems --file-system-id $file_system_id --query "FileSystems[*].LifeCycleState" --output text) ]
do
  echo "waiting for the file system to be available. file_system_id: $file_system_id" >> $LOGDIRNAME/$LOGFILENAME
done;

ARR_SUBNET=($(aws ec2 describe-subnets --filters "Name=tag:Name,Values=eksctl-node-altair-dev-cluster/SubnetPrivate*" --query "Subnets[*].SubnetId" --output text))

for S in "${ARR_SUBNET[@]}";
do
  echo "/*** create mount target for subnet. subnet-id: $S **/" >> $LOGDIRNAME/$LOGFILENAME
  aws efs create-mount-target --file-system-id $file_system_id --subnet-id $S --security-groups $security_group_id >> $LOGDIRNAME/$LOGFILENAME 2>&1
  if [ $? != 0 ]; then error ;fi
done

echo "/*** create namespace redis-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace redis-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret redis-access-creds **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic redis-access-creds --from-file=requirepass=$SECRETDIRNAME/redis-access-creds/requirepass.txt --namespace redis-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/1-storageclass.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/1-storageclass.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/2-persistentVolume.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../redis/2-persistentVolume.yaml | sed "s/\$fileSystemId/${file_system_id}/" | kubectl apply -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/3-persistentVolumeClaim.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/3-persistentVolumeClaim.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/4-service.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/4-service.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/5-statefulSet.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/5-statefulSet.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/6-service.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/6-service.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply redis/7-statefulSet.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../redis/7-statefulSet.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
