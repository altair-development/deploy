#!/bin/bash

echo "/*** delete altair-api **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../altair-api >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret git-access-creds-api **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-api-dev git-access-creds-api >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret api-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-api-dev api-env >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace altair-api-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace altair-api-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
