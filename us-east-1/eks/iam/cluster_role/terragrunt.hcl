locals {
account_id = include.root.locals.account_id
cluster_name = "hold"
}

include "root" {
  path= find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "iam")
}

inputs = {
  role_name= "eks-dev_cluster-role"
  policy_name= "eks-dev_cluster-policy"
  policy_description= "Cluster role used by the EKS Control Plane, allows access to K8s API and for nodes to join the cluster"

  assume_role_policy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

  aws_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}
