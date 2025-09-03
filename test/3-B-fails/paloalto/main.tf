data "azurerm_resource_group" "rg" {
  name     = var.rg_name
}

data "azurerm_virtual_hub" "hub1" {
  name                = var.hub_name
  resource_group_name = var.rg_name
}

resource "azurerm_palo_alto_virtual_network_appliance" "ngfw1" {
  name           = var.paloalto_fw_name
  virtual_hub_id = data.azurerm_virtual_hub.hub1.id
}
/*
## https://registry.terraform.io/modules/PaloAltoNetworks/swfw-modules/azurerm/latest/submodules/cloudngfw
module "swfw-modules_cloudngfw" {
  source  = "PaloAltoNetworks/swfw-modules/azurerm//modules/cloudngfw"
  version = "3.4.2"
  # insert the 6 required variables here ; name = "cloudngfw"
  name = var.paloalto_fw_name
  attachment_type = "vwan"
  management_mode = "rulestack"
  resource_group_name = var.rg_name
  region = var.region
  virtual_hub_id = var.hub_id
  cloudngfw_config = {
    plan_id= "panw-cngfw-payg"
    marketplace_offer_id = "pan_swfw_cloud_ngfw"
    rulestack_id = azurerm_palo_alto_local_rulestack.lrs.id
  }
  depends_on = [
    azurerm_palo_alto_local_rulestack.lrs,
    azurerm_public_ip.fwpip
  ]
}
#    create_public_ip = false
#    public_ip_name = "fw-pip"

*/

# create the first public IP for the Virtual Network Gateway1
resource "azurerm_public_ip" "fwpip" {
  name                = "fw-pip"
  location            = data.azurerm_virtual_hub.hub1.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones               = ["1", "2", "3"]
}


resource "azurerm_palo_alto_local_rulestack" "lrs" {
  name                  = "lrs1"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_virtual_hub.hub1.location
  anti_spyware_profile  = "BestPractice"
  anti_virus_profile    = "BestPractice"
  file_blocking_profile = "BestPractice"
  vulnerability_profile = "BestPractice"
  url_filtering_profile = "BestPractice"
}


resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "rulestack" {
  name                = "ngfw-rulestack1"
  resource_group_name = data.azurerm_resource_group.rg.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.lrs.id

  network_profile {
    public_ip_address_ids        =  [azurerm_public_ip.fwpip.id]
    virtual_hub_id               =  data.azurerm_virtual_hub.hub1.id
    network_virtual_appliance_id = azurerm_palo_alto_virtual_network_appliance.ngfw1.id
  }
  depends_on = [
    azurerm_public_ip.fwpip,
    azurerm_palo_alto_virtual_network_appliance.ngfw1
  ]
}


