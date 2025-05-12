terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.28.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "424b6326-529c-43c6-97ed-f04e0a11c40a"
  tenant_id       = "b7b023b8-7c32-4c02-92a6-c8cdaa1d189c"
}