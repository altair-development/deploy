#!/bin/bash

function error () {
  echo return code 1
  exit 1
}

cd `dirname $0`

. ./setting.sh

echo "/*** change context **/" > $LOGDIRNAME/$LOGFILENAME
kubectl config use-context $DELETE_CONTEXT >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

. ./delete-container-insights.sh
. ./delete-mongo.sh
. ./delete-redis.sh
. ./delete-api.sh
. ./delete-spa.sh
. ./delete-websock.sh
. ./delete-load-balancer-controller.sh

echo "/*** delete cluster node-altair-dev **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl delete cluster -f ../../node-altair.yml --wait >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo return code 0
exit