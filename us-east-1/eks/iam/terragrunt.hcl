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
  role_name= "bedrock"
  policy_name= "bedrock_policy"
  policy_description= "Grants permissions to interact with Amazon Bedrock services, including invoking foundation models and agents, if the principal (user or service) is authenticated"

  assume_role_policy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

  policy = {
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Action": ["eks:*"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/${local.cluster_name}-role"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ],
      "Resource": ["arn:aws:logs:*:*:*"]
    }]
  }
}
