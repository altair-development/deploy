#!/bin/bash

echo "/*** create namespace altair-api-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace altair-api-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** set readiness-gate label in namespace **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl label namespace altair-api-dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret api-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic api-env --from-file=$SECRETDIRNAME/env/api/.env --namespace altair-api-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret git-access-creds-api **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic git-access-creds-api --from-file=CLONE_URL=$SECRETDIRNAME/git/api/clone_url.txt --from-file=CLONE_BLANCH=$SECRETDIRNAME/git/api/clone_blanch.txt --namespace altair-api-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-api/1-service.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-api/1-service.yml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-api/2-ingress.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../altair-api/2-ingress.yaml | sed "s!\$CERTIFICATE_ARN!${CERTIFICATE_ARN}!" | kubectl apply -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-api/3-deployment.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-api/3-deployment.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi