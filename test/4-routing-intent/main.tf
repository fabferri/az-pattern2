data "azurerm_resource_group" "rg" {
  name     = var.rg_name
}


data "azurerm_palo_alto_virtual_network_appliance" "fw1" {
  name                = "fw1"
  virtual_hub_id      = data.azurerm_virtual_hub.hub1.id
}


data "azurerm_virtual_hub" "hub1" {
  name                = var.hub_name
  resource_group_name = var.rg_name
}

module "palo_alto" {
  source              = "./routing-intent"
  hub_id              = data.azurerm_virtual_hub.hub1.id
  palo_alto_fw_id     = azurerm_palo_alto_virtual_network_appliance.fw1.id
}