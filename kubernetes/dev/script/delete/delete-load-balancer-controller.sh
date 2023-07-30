#!/bin/bash

echo "/*** delete IngressClassParams and IngressClass **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../v2_4_7_ingclass.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete load balancer controller **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../v2_4_7_full.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/***  delete cert-manager **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1

echo "/*** delete iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete iamserviceaccount --region $REGION --name aws-load-balancer-controller --namespace kube-system --cluster node-altair-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
