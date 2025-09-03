variable "subscription_id" {
  type        = string
  description = "Location of the resource group."
}

variable "rg_location" {
  type        = string
  default     = "uksouth"
  description = "Location of the resource group."
}

variable "rg_name" {
  type        = string
  default     = "rg-test"
  description = "name of the resource group."
}

variable "hub_name" {
  type        = string
  default     = "hub1"
  description = "The name of the Virtual Hub"
}



