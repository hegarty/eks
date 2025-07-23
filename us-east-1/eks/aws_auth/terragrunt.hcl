dependency "cluster" {
  config_path = "../cluster"
}

dependency "nodegroup" {
  config_path = "../node_group"
}

include "root" {
  path= find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/aws_auth")
}

inputs = {
  cluster_endpoint = dependency.cluster.outputs.endpoint
  cluster_ca       = dependency.cluster.outputs.certificate_authority[0].data
  token            = dependency.cluster.outputs.eks_token

  map_roles = [
    {
      rolearn  = dependency.nodegroup.outputs.node_group_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes"
      ]
    },
    {
      rolearn  = "arn:aws:iam::891377023413:role/AWSReservedSSO_org-admin_12c4990cc7e091d8"
      username = "terence"
      groups   = [
        "system:masters"
      ]
    }
  ]

  kubernetes_provider = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.26"
  }
}
