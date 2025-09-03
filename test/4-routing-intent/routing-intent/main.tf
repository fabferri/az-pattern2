variable "hub_id" {
  type        = string
  description = "The ID of the Virtual Hub"
}

variable "palo_alto_fw_id" {
  type        = string
  description = "The ID of the palo alto firewall"
}

resource "azurerm_virtual_hub_routing_intent" "routingintent1" {
  name           = "routingintent-hub1"
  virtual_hub_id = var.hub_id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = var.palo_alto_fw_id
  }
}