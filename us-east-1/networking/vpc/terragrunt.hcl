locals {
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "networking/vpc")
}

inputs = {
  vpc_name                   = include.root.locals.account_name
  vpc_cidr                   = "10.0.24.0/21"
  enable_dns_support         = true
  enable_dns_hostnames       = true

  subnets  = [
    {
      use                   = "controller"
      type                  = "private"
      availability_zone_id  = "use1-az1"
      cidr                  = "10.0.24.0/28"
    },
    {
      use                   = "controller"
      type                  = "private"
      availability_zone_id  = "use1-az2"
      cidr                  = "10.0.24.16/28"
    },
    {
      use                   = "ingress-egress"
      type                  = "public"
      availability_zone_id  = "use1-az2"
      cidr                  = "10.0.24.128/25"
    },
    {
      use                   = "ingress-egress"
      type                  = "public"
      availability_zone_id  = "use1-az4"
      cidr                  = "10.0.25.0/25"
    },
    {
      use                   = "ingress-egress"
      type                  = "public"
      availability_zone_id  = "use1-az1"
      cidr                  = "10.0.25.128/25"
    },
    {
      use                   = "worker"
      type                  = "private"
      availability_zone_id  = "use1-az1"
      cidr                  = "10.0.26.0/23"
    },
    {
      use                   = "worker"
      type                  = "private"
      availability_zone_id  = "use1-az2"
      cidr                  = "10.0.28.0/23"
    },
    {
      use                   = "worker"
      type                  = "private"
      availability_zone_id  = "use1-az4"
      cidr                  = "10.0.30.0/23"
    },
  ]
}
