terraform {
  required_providers {
    aviatrix = {
      # Make sure to keep the version up to date with the controller version.
      # https://registry.terraform.io/providers/AviatrixSystems/aviatrix/latest/docs/guides/release-compatibility.
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.58.0"
    }
  }
  required_version = ">= 1.4.0"
}
