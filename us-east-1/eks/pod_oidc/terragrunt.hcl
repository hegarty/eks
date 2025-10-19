include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "cluster" {
  config_path = "../cluster"
}

terraform {
  source = format(include.root.locals.module_source, "eks/pod_oidc")
}

inputs = {
  cluster_name      = dependency.cluster.outputs.cluster_name
  oidc_issuer       = dependency.cluster.outputs["oidc_issuer"]
  resolve_conflicts = "OVERWRITE"
}
