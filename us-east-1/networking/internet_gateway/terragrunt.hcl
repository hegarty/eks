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
  source = format(include.root.locals.module_source, "networking/internet_gateway")
}

inputs = {
  name    = "eks-dev_internet-gateway"
  vpc_id  = dependency.vpc.outputs.vpc_id
}
