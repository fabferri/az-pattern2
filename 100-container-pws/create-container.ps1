###########################################
##   Run the script by command:
##
##  .\scriptName -adminUsername YOUR_USERNAME -adminPassword YOUR_PASSWORD
##
################# Input parameters #################
[CmdletBinding()]
param (
  [Parameter(Mandatory = $True, ValueFromPipeline = $false, HelpMessage = 'username administrator VMs', Position = 0)]
  [string]$adminUsername,
 
  [Parameter(Mandatory = $true, HelpMessage = 'password administrator VMs')]
  [string]$adminPassword
)

### Variables
$subscrName = "AzDev"
$rgName = "RG-cont01"
$location = "eastus"
$contName = "cont-01"

#
######################### MAIN #################################
$pwd = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential( $adminUsername, $pwd);

# Select the Azure subscription
$subscr = Get-AzSubscription -SubscriptionName $subscrName
Select-AzSubscription -SubscriptionId $subscr.Id 

# compose unique name for docker registry 
do {
  $tail1 = ([char[]](Get-Random -Input $( 65..90 + 97..122) -Count 5)) -join ""
  $tail2 = ([char[]](Get-Random -Input $(48..57) -Count 3)) -join ""
  $contNameRegistry = "dockReg" + $tail1 + $tail2
  $checkRegistry = (Test-AzContainerRegistryNameAvailability -Name $contNameRegistry).NameAvailable
} while ($checkRegistry -eq $false)

write-host -foregroundcolor cyan "docker registry name:$contNameRegistry"

try {     
  Get-AzResourceGroup -Name $rgName -Location $location -ErrorAction Stop     
  Write-Host 'RG already exists... skipping' -foregroundcolor Green -backgroundcolor Black
}
catch {     
  $rg = New-AzResourceGroup -Name $rgName -Location $location  -Force
}

try { 
  $registry = Get-AzContainerRegistry -ResourceGroupName $rgName -Name $contNameRegistry -ErrorAction Stop
  Write-Host 'Container registry already exists... skipping' -foregroundcolor Green -backgroundcolor Black
}
catch {
  # create a container registry
  # The registry name must be unique within Azure, and contain 5-50 alphanumeric characters.
  $registry = New-AzContainerRegistry -ResourceGroupName $rgName -Name $contNameRegistry -EnableAdminUser -Sku Basic -Location $location -Verbose
}

# get the credential to login in the container registry
$creds = Get-AzContainerRegistryCredential -ResourceGroupName $rgName -Name $contNameRegistry 


# run docker login to log in.
# A successful login returns Login Succeeded
$creds.Password | docker login $registry.LoginServer -u $creds.Username --password-stdin

# Now that you're logged in to the registry, you can push container images to it.
# the aci-helloworld image is a small Node.js application that serves a static HTML page showing the Azure Container Instances logo.
# to pull the public aci-helloworld image from Docker Hub
docker pull microsoft/aci-helloworld


# Before you can push an image to your Azure container registry, you must tag it with the fully qualified domain name (FQDN) of your registry. 
# The FQDN of Azure container registries are in the format <registry-name>.azurecr.io.
# Populate a variable with the full image tag. Include the login server, repository name ("aci-helloworld"), and image version ("v1"):
$image = $registry.LoginServer + "/aci-helloworld:v1"

#tag the image with docker tag:
docker tag microsoft/aci-helloworld $image

# docker push it to your registry:
docker push $image

# First, convert the registry credential to a PSCredential. 
# The New-AzContainerGroup command, which you use to create the container instance, requires it in this format.
$secpasswd = ConvertTo-SecureString $creds.Password -AsPlainText -Force
$pscred = New-Object System.Management.Automation.PSCredential($creds.Username, $secpasswd)

# Additionally, the DNS name label for your container must be unique within the Azure region you create it
$dnsname = "aci-demo-" + (Get-Random -Maximum 9999)

# deploy a container from the image in your registry with 1 CPU core and 1 GB of memory:
New-AzContainerGroup -ResourceGroup $rgName -Name "mycontainer" -Image $image -RegistryCredential $pscred -Cpu 1 -MemoryInGB 1 -DnsNameLabel $dnsname

# To monitor its status and determine when it's running
do {
  $status = (Get-AzContainerGroup -ResourceGroupName $rgName -Name mycontainer).ProvisioningState
  Write-host -ForegroundColor Cyan "current status: $status"
  sleep 5
} while ($status -eq "Succeeded")

$url = (Get-AzContainerGroup -ResourceGroupName $rgName -Name mycontainer).Fqdn
write-host "url: $url"
