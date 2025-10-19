#!/usr/bin/env bash
set -euo pipefail

# Configurable vars
AWS_REGION="us-east-1"
ACCOUNT_ID=891377023413
REPO="eks-dev/helloworld"
TAG="${1:-v0.1.0}"   # pass version tag as arg, default v0.1.0
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO}"

echo ">>> Building Go binary for linux/arm64 named helloworld"
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o helloworld .

echo ">>> Logging in to ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo ">>> Building Docker image..."
#docker buildx build --platform linux/arm64 -t helloworld:arm64 --load .
docker buildx build --platform linux/arm64 \
  -t "${REPO}:${TAG}" \
  -t "${ECR_URI}:${TAG}" .

echo ">>> Pushing to ECR..."
docker push "${ECR_URI}:${TAG}"

echo ">>> Done. Image available at: ${ECR_URI}:${TAG}"
