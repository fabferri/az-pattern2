terraform {
  required_version = ">=1.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.41.0"
    }
  }
}

variable "targetsubscription_id" {
  type        = string
  default     = "ee430ef2-e4f5-45df-a4fd-5da90bb82b2e"
  description = "subscription id"
}

provider "azurerm" {
  features {}
  subscription_id = var.targetsubscription_id
}
