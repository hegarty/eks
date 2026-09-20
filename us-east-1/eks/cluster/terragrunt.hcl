dependency "iam" {
  config_path = "../iam/cluster_role"
}

dependency "vpc" {
  config_path = "../../networking/vpc"
}

dependency "sg" {
  config_path = "../security_groups"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/cluster")
}

inputs = {
  cluster_name                                = "eks-dev"
  authentication_mode                         = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = false
  iam_arn                                     = dependency.iam.outputs.arn
  vpc_id                                      = dependency.vpc.outputs.vpc_id
  subnet_ids                                  = dependency.vpc.outputs.controller_subnets
  security_groups                             = ["${dependency.sg.outputs.id}"]

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Preserves eks-dev's original behavior after eks/cluster gained a
  # configurable (and now cheaper-by-default) enabled_cluster_log_types.
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
