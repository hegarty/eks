locals {
  vpc_name  = include.root.locals.account_name
  amp_rules =  file("amp_rules.yaml")
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = format(include.root.locals.module_source, "metrics/prometheus")
}

inputs = {
  env                     = "env"
  amp_alias               = "eks-dev_metrics"
  enable_rule_group       = true
  amp_rules               = local.amp_rules
  enable_alert_manager    = true
  amp_alert_manager_file  = "alertmanager.yml"
  enable_amp_logging      = true

  tags = {
    Env     = "dev"
  }
}
