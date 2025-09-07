 locals {
   #issuer      = dependency.irsa.outputs.oidc_issuer
   #issuer_host = replace(local.issuer, "https://", "")
 }

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "oidc" {
  config_path = "../../../pod_oidc"
}
/*
dependency "cluster" {
  config_path = "../cluster"
}
*/
terraform {
  source = format(include.root.locals.module_source, "iam")
}

inputs = {
  role_name           = "eks-dev_ebs-csi_role"
  policy_name         = "eks-dev-ebs-si_policy"
  policy_description  = "Permissions for the EBS_CSI AddOn"

  #oidc_issuer       = dependency.oidc.outputs.oidc_provider_arn
  #oidc_provider_arn = dependency.oidc.outputs.oidc_provider_arn
  #cluster_name      = dependency.cluster.outputs.cluster_name

  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = dependency.oidc.outputs.oidc_provider_arn }
      "Condition": {
        "StringEquals": {
          "${dependency.oidc.outputs.oidc_url}:aud": "sts.amazonaws.com",
          "${dependency.oidc.outputs.oidc_url}:sub": ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
        }
      }
    }]
  }

  aws_managed_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]

}
