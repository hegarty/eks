locals {

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
  source = format(include.root.locals.module_source, "eks/cluster")
}

inputs = {
    cluster_name    = "eks-dev"
    iam_arn         = dependency.iam.outputs.arn
    vpc_id          = dependency.vpc.outputs.vpc_id
    subnet_ids      = dependency.vpc.outputs.controller_subnets
    security_groups = ["${dependency.sg.outputs.id}"]
}
