module "sst" {
  source       = "terraform-aviatrix-modules/aws-sandbox-starter/aviatrix"
  version      = "1.0.2"
  keypair_name = var.keypair
}

output "sandbox_starter_url" {
  description = "The url for the sst instance"
  value       = "https://${module.sst.ip}"
}
