#!/bin/bash

echo "/*** create namespace altair-spa-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace altair-spa-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** set readiness-gate label in namespace **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl label namespace altair-spa-dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret spa-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic spa-env --from-file=$SECRETDIRNAME/env/spa/.env.local --namespace altair-spa-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** create secret git-access-creds-spa **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create secret generic git-access-creds-spa --from-file=CLONE_URL=$SECRETDIRNAME/git/spa/clone_url.txt --from-file=CLONE_BLANCH=$SECRETDIRNAME/git/spa/clone_blanch.txt --namespace altair-spa-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-spa/1-service.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-spa/1-service.yml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-spa/2-ingress.yaml **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../altair-spa/2-ingress.yaml | sed "s!\$CERTIFICATE_ARN!${CERTIFICATE_ARN}!" | kubectl apply -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** apply altair-spa/3-deployment.yml **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../altair-spa/3-deployment.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi