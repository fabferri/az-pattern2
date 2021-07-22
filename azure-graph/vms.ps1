# Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualMachines' | limit 1" 
# Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by location"
# Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualMachines' and properties.hardwareProfile.vmSize == 'Standard_B2s' | project name, resourceGroup"
# Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualmachines' and properties.hardwareProfile.vmSize == 'Standard_B2s' | extend disk = properties.storageProfile.osDisk.managedDisk | where disk.storageAccountType == 'Premium_LRS' | project disk.id"
# Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/disks' and id == '/subscriptions/<subscriptionId>/resourceGroups/MyResourceGroup/providers/Microsoft.Compute/disks/ContosoVM1_OsDisk_1_9676b7e1b3c44e2cb672338ebe6f5166'"
#
# # Use Resource Graph with the $ips variable to get the IP address of the public IP address resources
#Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where id in ('$($ips.publicIp -join "','")') | project ip = tostring(properties['ipAddress']) | where isnotempty(ip) | distinct ip"
$listVMs=Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Compute/virtualMachines' " 

foreach ($vm in $listVMs){
 $vm.id
 $vm.location
 $vm.name
 $vmSize=$vm.properties.hardwareProfile.vmSize
 write-host "vm location:"$vm.location"| vm name:"$vm.name"| vmsize:"$vmSize -ForegroundColor Cyan
}

Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' "
