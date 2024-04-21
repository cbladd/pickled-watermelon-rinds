#!/bin/bash

# Configuration Variables
ECS_CLUSTER_NAME="wordpress-cluster"
ECS_SERVICE_NAME="wordpress-service"
LB_NAME="wordpress-alb"
DB_CLUSTER_IDENTIFIER="wordpress-db-cluster"
REGION="us-west-2"  

echo "Checking ECS Service Status..."
aws ecs describe-services --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME --region $REGION | jq '.services[] | {serviceName: .serviceName, desiredCount: .desiredCount, runningCount: .runningCount, pendingCount: .pendingCount}'

echo "Checking ECS Task Health..."
TASK_ARNS=$(aws ecs list-tasks --cluster $ECS_CLUSTER_NAME --service-name $ECS_SERVICE_NAME --region $REGION | jq -r '.taskArns[]')
for TASK_ARN in $TASK_ARNS; do
    echo "Task: $TASK_ARN"
    aws ecs describe-tasks --cluster $ECS_CLUSTER_NAME --tasks $TASK_ARN --region $REGION | jq '.tasks[] | {taskArn: .taskArn, lastStatus: .lastStatus, healthStatus: .healthStatus, stopCode: .stopCode, stoppedReason: .stoppedReason}'
done

echo "Checking Load Balancer Target Health..."
TARGET_GROUP_ARN=$(aws elbv2 describe-load-balancers --names $LB_NAME --region $REGION | jq -r '.LoadBalancers[0].LoadBalancerArn')
TARGET_GROUPS=$(aws elbv2 describe-target-groups --load-balancer-arn $TARGET_GROUP_ARN --region $REGION | jq -r '.TargetGroups[].TargetGroupArn')
for TG_ARN in $TARGET_GROUPS; do
    echo "Target Group: $TG_ARN"
    aws elbv2 describe-target-health --target-group-arn $TG_ARN --region $REGION | jq '.TargetHealthDescriptions[] | {target: .Target.Id, healthStatus: .TargetHealth.State, reason: .TargetHealth.Reason, description: .TargetHealth.Description}'
done

echo "Checking RDS Database Availability..."
aws rds describe-db-clusters --db-cluster-identifier $DB_CLUSTER_IDENTIFIER --region $REGION | jq '.DBClusters[] | {dbClusterIdentifier: .DBClusterIdentifier, status: .Status}'

echo "Checking DNS Resolution for Load Balancer..."
LB_DNS_NAME=$(aws elbv2 describe-load-balancers --names $LB_NAME --region $REGION | jq -r '.LoadBalancers[0].DNSName')
echo "DNS Name: $LB_DNS_NAME"
nslookup $LB_DNS_NAME

echo "Checking Security Group Rules for Load Balancer..."
SG_IDS=$(aws elbv2 describe-load-balancers --names $LB_NAME --region $REGION | jq -r '.LoadBalancers[0].SecurityGroups[]')
for SG_ID in $SG_IDS; do
    echo "Security Group: $SG_ID"
    aws ec2 describe-security-groups --group-ids $SG_ID --region $REGION | jq '.SecurityGroups[] | {groupId: .GroupId, inboundRules: .IpPermissions, outboundRules: .IpPermissionsEgress}'
done
