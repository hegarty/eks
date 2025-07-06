locals {
  vpc_name  = include.root.locals.account_name
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "gateway" {
  config_path = "../../internet_gateway"

  mock_outputs = {
      id = "mock-gateway-output"
  }
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "networking/routes")
}

inputs = {
  route-table_prefix  = "eks-dev_public"
  vpc_id              = dependency.vpc.outputs.vpc_id
  subnets             = dependency.vpc.outputs.public_subnets
  destination_cidr    = "0.0.0.0/0"
  gateway_id          = dependency.gateway.outputs.id
}
