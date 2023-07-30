#!/bin/bash

echo "/*** delete altair-websock **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete -f ../../altair-websock >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret git-access-creds-websock **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-websock-dev git-access-creds-websock >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret git-access-creds-websock-monitor **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-websock-dev git-access-creds-websock-monitor >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret websock-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-websock-dev websock-env >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete secret websock-monitor-env **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete secret -n altair-websock-dev websock-monitor-env >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** delete namespace altair-websock-dev **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl delete namespace altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi
