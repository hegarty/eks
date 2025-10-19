dependency "cluster" {
    config_path = "../cluster"
}

dependency "iam" {
    config_path = "../iam/node_role"
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
  instance_types = ["c7g.large"]
  ami_type = "AL2023_ARM_64_STANDARD"
  capacity_type = "ON_DEMAND"

  block_device_mappings = [{
      device_name = "/dev/xvda"
      ebs = {
        volume_size = 20
        volume_type = "gp3"
        encrypted   = true
      }
  }]

  metadata_options = [{
    http_tokens = "required"
    http_put_response_hop_limit = 2
  }]

  associate_public_ip_address = true
  node_role_arn         = dependency.iam.outputs.arn
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
  EOF
}
