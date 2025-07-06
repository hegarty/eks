locals {
  vpc_name  = include.root.locals.account_name
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "nat" {
  config_path = "../../nat"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "networking/routes")
}

inputs = {
  route-table_prefix  = "eks-dev_controller"
  vpc_id              = dependency.vpc.outputs.vpc_id
  subnets             = dependency.vpc.outputs.controller_subnets
  destination_cidr    = "0.0.0.0/0"
  nat_ids             = dependency.nat.outputs.ids
}
