output "aws_account" {
  value = data.aws_caller_identity.aws_account.account_id
}

output "controller_private_ip" {
  value = module.aviatrix_controller_aws.private_ip
}

output "controller_public_ip" {
  value = module.aviatrix_controller_aws.public_ip
}
