#!/bin/bash

set -euo pipefail

base="/Users/terencehegarty/projects/hegarty/eks/us-east-1/networking"

log() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}

error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

run_destroy() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    log "Destroying resources in $dir"
    cd "$dir"
    terragrunt destroy --terragrunt-non-interactive -auto-approve || error "Failed to destroy resources in $dir"
  else
    error "Directory not found: $dir"
  fi
}

detach_igw_if_attached() {
  local igw_id="$1"

  log "Checking IGW attachment for $igw_id..."
  local vpc_id
  vpc_id=$(aws ec2 describe-internet-gateways \
    --internet-gateway-ids "$igw_id" \
    --query 'InternetGateways[0].Attachments[0].VpcId' \
    --output text 2>/dev/null || echo "none")

  if [[ "$vpc_id" != "none" && "$vpc_id" != "None" ]]; then
    log "Detaching IGW $igw_id from VPC $vpc_id..."
    aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" \
      || error "Failed to detach IGW $igw_id from VPC $vpc_id"
    sleep 5
  else
    log "IGW $igw_id is already detached."
  fi
}

# Step 1: Destroy routes
run_destroy "$base/routes/public"
run_destroy "$base/routes/controller"
run_destroy "$base/routes/worker"

# Step 2: Destroy NAT Gateways
run_destroy "$base/nat"

# Step 3: Detach IGW manually (before destroy)
cd "$base/internet_gateway"
log "Getting IGW ID from Terraform output..."
igw_id=$(terragrunt output -raw internet_gateway_id)
detach_igw_if_attached "$igw_id"

# Step 4: Destroy Internet Gateway
run_destroy "$base/internet_gateway"

# Step 5: Finally destroy the VPC
run_destroy "$base/vpc"

log "✅ Network infrastructure teardown complete."

