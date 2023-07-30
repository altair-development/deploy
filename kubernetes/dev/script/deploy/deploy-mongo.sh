#!/bin/bash

# Amazon EBS CSI ドライバーのIAM ロールを作成し、作成したサービスアカウントにアタッチ
echo "/*** create iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create iamserviceaccount --name ebs-csi-controller-sa --region $REGION --namespace kube-system --cluster node-altair-dev --role-name AmazonEKS_EBS_CSI_DriverRole --role-only --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# Amazon EBS CSIアドオンを追加する
echo "/*** create aws-ebs-csi-driver addon **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create addon --name aws-ebs-csi-driver --region $REGION --cluster node-altair-dev --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole --force >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create namespace mongo-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace mongo-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret mongo-access-creds **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic mongo-access-creds --from-file=DB_USER_ADMIN=$SECRETDIRNAME/mongo-access-creds/db_user_admin.txt --from-file=DB_PASS_ADMIN=$SECRETDIRNAME/mongo-access-creds/db_pass_admin.txt --namespace mongo-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret mongo-key **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic mongo-key --from-file=$SECRETDIRNAME/mongo-key/mongodb-keyfile --namespace mongo-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret mongo-script  **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic mongo-script --from-file=$SECRETDIRNAME/mongo-script/createDbAdmin.js --from-file=$SECRETDIRNAME/mongo-script/createDbAltair.js --namespace mongo-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply mongo  **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../mongo >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi