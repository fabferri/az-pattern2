https://github.com/abudilovskiy-panw/cngfw-azure-terraform-blog

https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/resources/palo_alto_network_virtual_appliance
https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/resources/palo_alto_next_generation_firewall_vhub_local_rulestack
https://registry.terraform.io/providers/hashicorp/azurerm/3.113.0/docs/resources/palo_alto_local_rulestack_rule

******* Go to the folder 1:
terraform init -upgrade
terraform plan -out main.tfplan
terraform apply main.tfplan


https://www.youtube.com/watch?v=QrSfASpVE14


│ Error: performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: PaymentRequired: SaaS Purchase Payment Check Failed as validationResponse was {"isEligible":false,"errorMessage":"Plan 'panw-cloud-ngfw-payg' is defined as stop sell in offer 'pan_swfw_cloud_ngfw'."}
│
│   with module.palo_alto.azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.cngfw-hub1,
│   on paloalto\main.tf line 69, in resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "cngfw-hub1":
│   69: resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "cngfw-hub1" {
│
│ performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: PaymentRequired: SaaS Purchase Payment Check      
│ Failed as validationResponse was 
{"isEligible":false,"errorMessage":"Plan 'panw-cloud-ngfw-payg' is defined as stop sell in      
│ offer 'pan_swfw_cloud_ngfw'."}

================

Error: performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: BadRequest: IP Address already in use, please check the Firewall and Public IP Address configurations: /subscriptions/ee430ef2-e4f5-45df-a4fd-5da90bb82b2e/resourceGroups/rg1-wan/providers/Microsoft.Network/publicIPAddresses/fw-pip
│
│   with module.palo_alto.azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.rulestack,
│   on paloalto\main.tf line 66, in resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "rulestack":
│   66: resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "rulestack" {
│
│ performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: BadRequest: IP Address already in use, please check the Firewall   
│ and Public IP Address configurations:
│ /subscriptions/ee430ef2-e4f5-45df-a4fd-5da90bb82b2e/resourceGroups/rg1-wan/providers/Microsoft.Network/publicIPAddresses/fw-pip

