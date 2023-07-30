#!/bin/bash

# IAM OIDC プロバイダーを作成し、クラスターに関連付け
# echo "/*** create oidc-provider **/" >> $LOGDIRNAME/$LOGFILENAME
# eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=$CLUSTER_NAME --approve >> $LOGDIRNAME/$LOGFILENAME 2>&1
# if [ $? != 0 ]; then error ;fi

echo "/*** create namespace amazon-cloudwatch **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl create namespace amazon-cloudwatch >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# cloudwatch-agentサービスアカウントを作成し、CloudWatchAgentServerPolicyロールをにアタッチ
echo "/*** create iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create iamserviceaccount --name cloudwatch-agent --namespace amazon-cloudwatch --cluster $CLUSTER_NAME --region $REGION --approve --override-existing-serviceaccounts --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# fluent-bitサービスアカウントを作成し、CloudWatchAgentServerPolicyロールをにアタッチ
echo "/*** create iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create iamserviceaccount --name fluent-bit --namespace amazon-cloudwatch --cluster $CLUSTER_NAME --region $REGION --approve --override-existing-serviceaccounts --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'

echo "/*** apply cwagent-fluent-bit-quickstart  **/" >> $LOGDIRNAME/$LOGFILENAME
cat ../../cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${CLUSTER_NAME}'/;s/{{region_name}}/'${REGION}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - >> $LOGDIRNAME/$LOGFILENAME
if [ $? != 0 ]; then error ;fi