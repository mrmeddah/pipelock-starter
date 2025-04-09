#!/bin/bash
set -e  


AWS_PROFILE="default"
AWS_REGION="us-east-1"
TF_ENV_DIR="../infra/terraform/environments/dev"

#Secrets Manager usually takes a 7 day caution period (Had command will force delete it skipping waiting period)
aws secretsmanager delete-secret \
  --secret-id metabase-db-credentials \
  --region $AWS_REGION \
  --force-delete-without-recovery \
  --profile $AWS_PROFILE || true

#Hadi pour Terraform Destroy (Variable dyal path fin kyn env)
cd $TF_ENV_DIR
terraform init
terraform destroy -auto-approve
cd -

#Orphaned Dependant Resources li kib9aw (Mostly Network related resources)
echo "Cleaning up orphaned resources..."
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=metabase-vpc" --query "Vpcs[].VpcId" --output text | while read VPC_ID; do
  
  aws ec2 delete-vpc --vpc-id $VPC_ID --region $AWS_REGION --profile $AWS_PROFILE || true
done

#  Hadi pour ECS
aws ecs delete-cluster \
  --cluster metabase-dev \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true

# Hadi pour Load Balancer
aws elbv2 delete-load-balancer \
  --load-balancer-arn $(aws elbv2 describe-load-balancers --names "metabase-dev" --query "LoadBalancers[0].LoadBalancerArn" --output text) \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true

# Log group d cloud watch
aws logs delete-log-group \
  --log-group-name "/ecs/metabase-dev" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true

aws logs delete-log-group \
  --log-group-name "metabase-vpc-flow-logs" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true

echo "Sf Salina haha!"