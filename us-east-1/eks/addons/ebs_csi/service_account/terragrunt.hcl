 locals {
 }

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "iam" {
  config_path = "../role"
}

dependency "cluster" {
  config_path = "../../../cluster"
}

terraform {
  source = format(include.root.locals.module_source, "eks/addons/service_account")
}

inputs = {
  cluster_name      = dependency.cluster.outputs.cluster_name
  name              = "eks-dev-ebs-csi-driver"
  namespace         = "kube-system"
  service_role_arn  = dependency.iam.outputs.arn
}
