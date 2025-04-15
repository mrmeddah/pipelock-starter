#!/bin/bash
set -e

echo "Fetching ECR repository URL from Terraform..."
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null) || {
    echo "Error: 'ecr_repository_url' output not found in Terraform state."
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

echo "Creating custom Dockerfile with RDS CA certificate..."
cat <<EOF > Dockerfile
FROM metabase/metabase:latest
COPY rds-ca-2019-root.pem /usr/local/share/ca-certificates/rds-ca-2019-root.crt
RUN update-ca-certificates
EOF

echo "Building custom Metabase image..."
docker build -t metabase-custom:latest . || {
    echo "Failed to build custom image"
    exit 1
}

echo "Tagging image for ECR..."
docker tag metabase-custom:latest "$ECR_URL:latest" || {
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