locals {
  vpc_name  = include.root.locals.account_name
}

dependency "vpc" {
  config_path = "../vpc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "networking/nat_gateway")
}

inputs = {
  prefix    = "eks-dev-nat"
  subnet_ids  = dependency.vpc.outputs.public_subnets
}
