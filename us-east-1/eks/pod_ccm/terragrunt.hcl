 locals {
   #issuer      = dependency.irsa.outputs.oidc_issuer
   #issuer_host = replace(local.issuer, "https://", "")
 }

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "oidc" {
  config_path = "../pod_oidc"
}

dependency "cluster" {
  config_path = "../cluster"
}

terraform {
  source = format(include.root.locals.module_source, "iam")
}

inputs = {
  role_name           = "eks-dev-ccm"
  policy_name         = "eks-dev-ccm-policy"
  policy_description  = "Permissions for AWS Cloud Controller Manager"

  oidc_issuer       = dependency.oidc.outputs.oidc_provider_arn
  #oidc_provider_arn = dependency.oidc.outputs.oidc_provider_arn
  cluster_name      = dependency.cluster.outputs.cluster_name

  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = dependency.oidc.outputs.oidc_provider_arn }
      Condition = {
        StringEquals = {
          "${dependency.oidc.outputs.oidc_issuer_host}:aud" = "sts.amazonaws.com"
          "${dependency.oidc.outputs.oidc_issuer_host}:sub" = "system:serviceaccount:kube-system:aws-cloud-controller-manager"
        }
      }
    }]
  }

  policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "ec2:Describe*",
        "ec2:CreateTags",
        "elasticloadbalancing:*",
        "iam:CreateServiceLinkedRole",
        "kms:DescribeKey"
      ]
      Resource = ["*"]
    }]
  }

}
