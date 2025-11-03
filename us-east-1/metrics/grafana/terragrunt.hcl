locals {
  vpc_name  = include.root.locals.account_name
  #amp_rules =  file("amp_rules.yaml")
}

dependency "iam" {
  config_path = "../iam"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "metrics/grafana")
}

inputs = {
  amg_name                = "prod-grafana"
  amg_description         = "Managed Grafana for production observability"
  amg_account_access_type = "CURRENT_ACCOUNT"
  amg_auth_providers      = ["AWS_SSO"]
  amg_data_sources        = ["PROMETHEUS", "CLOUDWATCH"]
  amg_permission_type     = "SERVICE_MANAGED"
  amg_iam_role_arn        = dependency.iam.outputs.arn

  tags = {
    Env     = "dev"
  }
}
