terraform {
  required_providers {
    aviatrix = {
      # Make sure to keep the version up to date with the controller version.
      # https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/guides/release-compatibility.
      source  = "aviatrixsystems/aviatrix"
      version = "= 2.20.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.63.0"
    }
  }
  required_version = ">= 1.0.0"
}
