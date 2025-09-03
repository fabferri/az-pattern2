data "azurerm_resource_group" "rg" {
  name     = var.rg_name
}

data "azurerm_virtual_hub" "hub1" {
  name                = var.hub_name
  resource_group_name = var.rg_name
}

module "palo_alto" {
  source              = "./paloalto"
  rg_name             = var.rg_name
  region              = var.rg_location
  resource_group_location = var.rg_location
  hub_name            = var.hub_name
  hub_id              = data.azurerm_virtual_hub.hub1.id
}

