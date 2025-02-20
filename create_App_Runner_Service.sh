#! /usr/bin/bash
######################################################################
# Author Ferrin Dsouza
#
# Create an AWS app runner service using the container image 
######################################################################

set -e
set -x

AWS_REGION="us-east-1"
SERVICE_NAME="nginx-simple-web-app-service"
REPOSITORY_NAME="nginx-web-app"
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ECR_IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:latest"
ROLE_NAME="AppRunnerECRAccessRole"
CONTAINER_PORT=80

#  check if IAM Role Exists
ROLE_NAME="AppRunnerECRAccessRole"
ROLE_ARN=$(aws iam get-role --role-name ${ROLE_NAME} --query "Role.Arn" --output text 2>/dev/null)


#  create IAM role for App runner if dosen't exist
if [ -z "$ROLE_ARN" ]; then
    echo "Creating IAM role for App Runner..."
    ROLE_ARN=$(aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document '{
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": { "Service": "build.apprunner.amazonaws.com" },
            "Action": "sts:AssumeRole"
          }]
        }' --query "Role.Arn" --output text)

    # attach  necessary policy for ECR access
    aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess

    echo "IAM role created: ${ROLE_ARN}"
else
    echo "Using existing IAM Role: ${ROLE_ARN}"
fi

# Deploy ARS
aws apprunner create-service --service-name ${SERVICE_NAME} \
    --source-configuration "AuthenticationConfiguration={AccessRoleArn=${ROLE_ARN}},ImageRepository={ImageIdentifier=${ECR_IMAGE_URI},ImageRepositoryType=ECR,ImageConfiguration={Port=${CONTAINER_PORT}}}" \
    --region ${AWS_REGION}

echo "App Runner service ${SERVICE_NAME} is deploying..."