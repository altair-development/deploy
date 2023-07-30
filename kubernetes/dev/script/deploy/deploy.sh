#!/bin/bash

function error () {
  echo return code 1
  exit 1
}

cd `dirname $0`

. ./setting.sh

echo "/*** create cluster **/" > $LOGDIRNAME/$LOGFILENAME
cat ../../node-altair.yml | sed "s!\$PUBLIC_WORKERS_PUBLIC_KEY_PATH!${PUBLIC_WORKERS_PUBLIC_KEY_PATH}!" | sed "s!\$PRIVATE_WORKERS_PUBLIC_KEY_PATH!${PRIVATE_WORKERS_PUBLIC_KEY_PATH}!" | eksctl create cluster -f - >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

. ./deploy-load-balancer-controller.sh

. ./deploy-mongo.sh

. ./deploy-redis.sh

pods=($(kubectl get pods -n mongo-dev -o 'jsonpath={..metadata.name}'))
while [[ ${#pods[@]} < $MONGO_REPL_CNT ]]; do
  echo "Preparing to start mongo..." >> $LOGDIRNAME/$LOGFILENAME 2>&1
  sleep 10
  pods=($(kubectl get pods -n mongo-dev -o 'jsonpath={..metadata.name}'))
done

for P in ${pods[@]}; do
  while [[ $(kubectl get pods -n mongo-dev $P -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo "waiting for ${P}" >> $LOGDIRNAME/$LOGFILENAME 2>&1
    sleep 10;
  done
  echo "${P} condition met" >> $LOGDIRNAME/$LOGFILENAME 2>&1
done

pods=($(kubectl get pods -n redis-dev -o 'jsonpath={..metadata.name}'))
while [[ ${#pods[@]} < $REDIS_REPL_CNT ]]; do
  echo "Preparing to start redis..." >> $LOGDIRNAME/$LOGFILENAME 2>&1
  sleep 10
  pods=($(kubectl get pods -n redis-dev -o 'jsonpath={..metadata.name}'))
done

for P in ${pods[@]}; do
  while [[ $(kubectl get pods -n redis-dev $P -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo "waiting for ${P}" >> $LOGDIRNAME/$LOGFILENAME 2>&1
    sleep 10;
  done
  echo "${P} condition met" >> $LOGDIRNAME/$LOGFILENAME 2>&1
done

. ./deploy-altair-api.sh

. ./deploy-altair-spa.sh

. ./deploy-altair-websock.sh

. ./deploy-container-insights.sh

echo "/*** aws-load-balancer-controller **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** altair-api-ingress-dev ADDRESS **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl get ingress/altair-api-ingress-dev -n altair-api-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** altair-spa-ingress-dev ADDRESS **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl get ingress/altair-spa-ingress-dev -n altair-spa-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** altair-websock-ingress-dev ADDRESS **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl get ingress/altair-websock-ingress-dev -n altair-websock-dev >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo return code 0
exit