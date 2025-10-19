locals {
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "ecr")
}

inputs = {
  name                  = "eks-dev/helloworld"
  image_tag_mutability  = "MUTABLE"
  scan_on_push          = true
}
