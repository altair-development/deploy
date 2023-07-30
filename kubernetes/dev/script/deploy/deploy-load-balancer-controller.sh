#!/bin/bash

# IAM OIDC プロバイダーを作成し、クラスターに関連付け
echo "/*** create oidc-provider **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl utils associate-iam-oidc-provider --region $REGION --cluster node-altair-dev --approve >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# IAM ポリシーの作成　※ポリシーのバージョンがv1.1.8と異なる場合のみ古いのを削除して実施
# echo "/*** create AWSLoadBalancerControllerIAMPolicy **/" >> $LOGDIRNAME/$LOGFILENAME
# aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://${ROOTDIRNAME}/iam_policy.json >> $LOGDIRNAME/$LOGFILENAME 2>&1
# if [ $? != 0 ]; then error ;fi

# # Kubernetes サービスアカウント・クラスターロールバインディングを作成
# echo "/*** apply rbac-role **/" >> $LOGDIRNAME/$LOGFILENAME
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.8/docs/examples/rbac-role.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
# if [ $? != 0 ]; then error ;fi

# ALB Ingress Controller の IAM ロールを作成し、作成したサービスアカウントにアタッチ
echo "/*** create iamserviceaccount **/" >> $LOGDIRNAME/$LOGFILENAME
eksctl create iamserviceaccount --region $REGION --cluster=node-altair-dev --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy --approve >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# cert-manager をデプロイ
echo "/*** deploy cert-manager **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** waiting for cert-manager to be ready **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl -n cert-manager wait pod --for=condition=Ready --all >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** wait an additional 60 seconds **/" >> $LOGDIRNAME/$LOGFILENAME
sleep 60

# ALB Ingress Controller をデプロイ
echo "/*** apply load balancer controller **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../v2_4_7_full.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

echo "/*** waiting for load balancer controller to be ready **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl -n kube-system wait pod -l app.kubernetes.io/name=aws-load-balancer-controller --for=condition=Ready >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi

# IngressClassおよびIngressClassParamsマニフェストをデプロイ
echo "/*** apply IngressClassParams and IngressClass **/" >> $LOGDIRNAME/$LOGFILENAME
kubectl apply -f ../../v2_4_7_ingclass.yaml >> $LOGDIRNAME/$LOGFILENAME 2>&1
if [ $? != 0 ]; then error ;fi