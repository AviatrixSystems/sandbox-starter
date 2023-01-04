variable "region" { default = "us-east-1" }
variable "az" { default = "us-east-1a" }

# VPC CIDR and subnet for the controller.
variable "vpc_cidr" { default = "10.255.0.0/20" }
variable "vpc_subnet" { default = "10.255.0.0/28" }

variable "controller_license_type" { default = "meteredplatinum" }
variable "pre_existing_iam_roles" { default = false }

variable "account_email" { default = "replace_account_email" }
variable "admin_password" { default = "r3place_Admin_password" }
variable "aws_account_name" { default = "aws-account" }
variable "controller_version" { default = "replace_controller_version" }
variable "instance_type" { default = "t3.large" }
