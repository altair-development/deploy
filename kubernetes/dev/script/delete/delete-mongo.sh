#!/bin/bash

echo "/*** delete mongo **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../mongo >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret mongo-access-creds **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n mongo-dev mongo-access-creds >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret mongo-key **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n mongo-dev mongo-key >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret mongo-script **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n mongo-dev mongo-script >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace mongo-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace mongo-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete aws-ebs-csi-driver addon **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete addon --cluster node-altair-dev --name aws-ebs-csi-driver --region $REGION >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete iamserviceaccount --region $REGION --name ebs-csi-controller-sa --namespace kube-system --cluster node-altair-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi