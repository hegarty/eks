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
  role_name= "eks-dev_grafana-role"
  policy_name= "eks-dev_grafana-policy"
  policy_description= "Grant Grafana the actions to read from Prometheus"

  assume_role_policy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "grafana.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

  policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "aps:ListWorkspaces",
        "aps:DescribeWorkspace",
        "aps:QueryMetrics",
        "aps:GetLabels",
        "aps:GetSeries",
        "aps:GetMetricMetadata"
      ]
      Resource = ["*"]
    }]
  }

  aws_managed_policies = []
}
