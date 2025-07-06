locals {
  account_name   = "eks" #account-name + purpose
  aws_account_id = get_env("EKS_DEV_ACCOUNT_ID")
}
