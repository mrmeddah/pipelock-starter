#!/bin/bash
set -e  


echo "Fetching ECR repository URL from Terraform..."
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null) || {
    echo "Error: 'ecr_repository_url' output not found in Terraform state."
    echo "Make sure you've:"
    echo "1. Added the ECR repository output to your Terraform config"
    echo "2. Run 'terraform apply'"
    exit 1
}


REGISTRY=$(echo "$ECR_URL" | cut -d'/' -f1)
REPO_NAME=$(echo "$ECR_URL" | cut -d'/' -f2)

echo "Authenticating Docker with ECR ($REGISTRY)..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$REGISTRY" || {
    echo "Failed to authenticate with ECR"
    exit 1
}

echo "Pulling Metabase image from Docker Hub..."
docker pull metabase/metabase:latest || {
    echo "Failed to pull Metabase image"
    exit 1
}

echo "Tagging image for ECR..."
docker tag metabase/metabase:latest "$ECR_URL:latest" || {
    echo "Failed to tag image"
    exit 1
}

echo "Pushing image to ECR..."
docker push "$ECR_URL:latest" || {
    echo "Failed to push image to ECR"
    exit 1
}

echo "Success! Image pushed to:"
echo "  $ECR_URL:latest"