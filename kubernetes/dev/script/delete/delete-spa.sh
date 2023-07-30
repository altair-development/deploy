#!/bin/bash

echo "/*** delete altair-spa **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../altair-spa >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret git-access-creds-spa **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-spa-dev git-access-creds-spa >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret spa-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-spa-dev spa-env >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace altair-spa-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace altair-spa-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
