dependency "cluster" {
  config_path = "../../cluster"
}

dependency "iam" {
  config_path = "../../pod_oidc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/addons/ebs_csi")
}

inputs = {
  cluster_name      = dependency.cluster.outputs.cluster_name
  addon_name        = "aws-ebs-csi-driver"
  ebs_csi_role_arn  = dependency.iam.outputs.ebs_csi_role_arn
  resolve_conflicts = "OVERWRITE"
}
