data "aws_caller_identity" "aws_account" {}

module "aviatrix_controller_aws" {
  source                      = "AviatrixSystems/aws-controller/aviatrix"
  version                     = "1.0.3"
  create_iam_roles            = var.pre_existing_iam_roles ? false : true
  access_account_email        = var.account_email
  access_account_name         = var.aws_account_name
  admin_email                 = var.account_email
  admin_password              = var.admin_password
  aws_account_id              = data.aws_caller_identity.aws_account.account_id
  controller_version          = var.controller_version
  termination_protection      = false
  incoming_ssl_cidrs          = ["0.0.0.0/0"]
  instance_type               = var.instance_type
  type                        = "BYOL"
  controller_launch_wait_time = "210"
  vpc_cidr                    = var.vpc_cidr
  subnet_cidr                 = var.vpc_subnet
}
