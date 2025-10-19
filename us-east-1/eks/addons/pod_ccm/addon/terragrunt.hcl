dependency "cluster" {
  config_path = "../../../cluster"
}

dependency "service_role" {
  config_path = "../role"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/addons/aws")
}

inputs = {
  cluster_name                = dependency.cluster.outputs.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.47.0-eksbuild.1"   # pin; or change when you upgrade the cluster
  service_role_arn            = dependency.service_role.outputs.arn
  resolve_conflicts_on_update = "OVERWRITE"

  # aws_eks_addon expects a **JSON string** here
  configuration_values = jsonencode({
    controller = {
      # helps when nodes are not “initialized” yet (external CCM path)
      tolerations = [
        { key = "node.kubernetes.io/not-ready",                         operator = "Exists", effect = "NoSchedule" },
        { key = "node.cloudprovider.kubernetes.io/uninitialized",       operator = "Equal",  value = "true", effect = "NoSchedule" }
      ]
    }
    node = {
      tolerations = [
        { key = "node.kubernetes.io/not-ready",                         operator = "Exists", effect = "NoSchedule" },
        { key = "node.cloudprovider.kubernetes.io/uninitialized",       operator = "Equal",  value = "true", effect = "NoSchedule" }
      ]
    }
  })

  tags = {
    environment = "dev"
  }
}
