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
  # inputs for node role
  role_name         = "eks-dev_node_role"
  policy_name       = "eks-dev_node_policy"
  policy_description= "Allows worker nodes to register and operate in EKS"

  assume_role_policy = {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }

  policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ec2:DescribeAvailabilityZones"
      ]
      Resource = ["*"]
    }]
  }

  aws_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
