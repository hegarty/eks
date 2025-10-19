locals {

}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "eks/access_entries/users")
}

inputs = {
    cluster_name      = "eks-dev"
    #principal_arn     = "arn:aws:iam::891377023413:role/AWSReservedSSO_org-admin_96b243dc9e5d3c2c"
    principal_arn     = "arn:aws:iam::891377023413:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_org-admin_96b243dc9e5d3c2c"
    policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope_type = "cluster"
}
