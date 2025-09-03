
variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."
}

variable "region" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}
variable "rg_name" {
  type        = string
  description = "name of the resource group."
}

variable "hub_name" {
  type        = string
  description = "The name of the Virtual Hub"
}

variable "hub_id" {
  type        = string
  description = "The ID of the Virtual Hub"
}

variable "paloalto_fw_name" {
  type        = string
  default     = "ngfw1"
  description = "The name of the Palo Alto Firewall"
}



