include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "cloudwatch/log_group")
}

inputs = {
  log_group_name    = "/aws/eks/eks-dev/cluster"
  retention_in_days = 3
}
