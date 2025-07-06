#!/bin/bash

base=/Users/terencehegarty/projects/hegarty/eks/us-east-1/networking
cd $base/vpc
terragrunt apply -auto-approve

cd $base/internet_gateway
terragrunt apply -auto-approve

cd $base/nat
terragrunt apply -auto-approve

cd $base/routes/public
terragrunt apply -auto-approve

cd $base/routes/controller
terragrunt apply -auto-approve

cd $base/routes/worker
terragrunt apply -auto-approve
