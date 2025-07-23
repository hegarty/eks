locals {

}

dependency "cluster" {
    config_path = "../cluster"
}

dependency "iam" {
    config_path = "../iam"
}

dependency "vpc" {
    config_path = "../../networking/vpc"
}

dependency "sg" {
    config_path = "../security_groups"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/node_group")
}

inputs = {
  name    = "eks-dev"
  instance_type = "m7g.large"

  ami_most_recent = true
  ami_owners      = ["amazon"]
  ami_filters = [
    {
      name   = "owner-alias"
      values = ["amazon"]
    },
    {
      name   = "name"
      values = ["amazon-eks-arm64-node-1.29-*"]
    },
    {
      name   = "architecture"
      values = ["arm64"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "root-device-type"
      values = ["ebs"]
    }
  ]

  associate_public_ip_address = true
  iam_arn         = dependency.iam.outputs.arn
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_ids      = dependency.vpc.outputs.worker_subnets
  cluster_name    = dependency.cluster.outputs.cluster_name
  scaling_desired_size = 1
  scaling_max_size     = 3
  scaling_min_size     = 1

  user_data = <<EOF
  #!/bin/bash
  set -ex
  /etc/eks/bootstrap.sh ${dependency.cluster.outputs.cluster_name} \
  --b64-cluster-ca ${dependency.cluster.outputs.certificate-authority[0].data} \
  --apiserver-endpoint ${dependency.cluster.outputs.api-server-endpoint} \
  --dns-cluster-ip ${dependency.vpc.outputs.vpc_cidr} \
  EOF
}
