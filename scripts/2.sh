#!/bin/bash

# hAD SCRIPT destroys already existed resources o kiw9e3 lihom conflict 7ite deja kynin b same name, "ghnkhdem mn db b'scripts 7ite sf mab9a endi jehd l'kola resource"

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo " 7yed ELB Target Group"
aws elbv2 delete-target-group --target-group-arn $(aws elbv2 describe-target-groups --names metabase-dev --region $REGION --query "TargetGroups[0].TargetGroupArn" --output text)

echo " 7yed IAM Policies"
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/metabase-ecs-secrets-access
aws iam delete-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/metabase-s3-export-access

echo " 7yed RDS DB Parameter Group"
aws rds delete-db-parameter-group --db-parameter-group-name metabase-postgres12

echo " 7yed CloudWatch Log Group"
aws logs delete-log-group --log-group-name metabase-vpc-flow-logs

echo " Finished."
