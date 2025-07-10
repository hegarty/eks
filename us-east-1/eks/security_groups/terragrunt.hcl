locals {
    ingress = file("ingress.json")
    egress  = file("egress.json")
}

dependency "iam" {
    config_path = "../iam"
}

dependency "vpc" {
    config_path = "../../networking/vpc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "networking/security_groups")
}

inputs = {
    sg_prefix       = "eks-dev"
    vpc_id          = dependency.vpc.outputs.vpc_id
    ingress_rules   = local.ingress
    egress_rules    = local.egress
}
