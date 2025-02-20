#!/usr/bin/bash
##############################################################
# Author: Ferrin Dsouza
# 
# create a script to push docker image to Amazon ECR
#
##############################################################

# set debug variables
set -e # exit on error
set -x # print each command before execuion
set -o # exits on option specified so if set -o pipefail then script exits if LHS of pipe fails.

# setting variables
REPOSITORY_NAME=nginx-web-app
AWS_REGION=us-east-1
IMAGE_TAG=latest

# authenticate Docker to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.${AWS_REGION}.amazonaws.com

#  check if repo exists (OPTIONAL)
REPO_URI=$(aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text 2>/dev/null)

# if repo dosen't exist create it
if [ -z "$REPO_URI" ]; then
    aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${AWS_REGION}
    REPO_URI=$(aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
fi

# tag your docker image
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${REPO_URI}:${IMAGE_TAG}

# Push the image to ecr
docker push ${REPO_URI}:${IMAGE_TAG}

echo "Docker Image Pushed To ECR: ${REPO_URI}:${IMAGE_TAG}"
