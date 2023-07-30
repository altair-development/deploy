#!/bin/bash

echo "/*** create namespace altair-websock-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** set readiness-gate label in namespace **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl label namespace altair-websock-dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret websock-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic websock-env --from-file=$SECRETDIRNAME/env/websock/.env --namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret websock-monitor-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic websock-monitor-env --from-file=$SECRETDIRNAME/env/websock-monitor/.env --namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret git-access-creds-websock **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic git-access-creds-websock --from-file=CLONE_URL=$SECRETDIRNAME/git/websock/clone_url.txt --from-file=CLONE_BLANCH=$SECRETDIRNAME/git/websock/clone_blanch.txt --namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret git-access-creds-websock-monitor **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic git-access-creds-websock-monitor --from-file=CLONE_URL=$SECRETDIRNAME/git/websock-monitor/clone_url.txt --from-file=CLONE_BLANCH=$SECRETDIRNAME/git/websock-monitor/clone_blanch.txt --namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-websock/1-service.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-websock/1-service.yml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-websock/2-ingress.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../altair-websock/2-ingress.yaml | sed "s!\$CERTIFICATE_ARN!${CERTIFICATE_ARN}!" | kubectl apply -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-websock/3-deployment.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-websock/3-deployment.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi