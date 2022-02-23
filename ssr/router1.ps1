#  Deployment of smart router2
#
#  NOTE: 
#      smart router requires the public IP address of the condutor.
#      Conductor has to be deployed before smart routers.
#
#
# VARIABLES:
#   $adminUsername: administrator username
#   $adminPassword: administrator RSA key to connect to the smart router via SSH
#
#   $subscriptionName: name of the Azure subscription ID
#   $location : Azure region where depoyed the smart router
#   $armTemplateFile: ARM template file
#   $conductorPubIPName: name of public IP of the conductor. Conductor has to be deployed before smart routers.
#
#
[CmdletBinding()]
param (
  [Parameter( Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'VMs administrator username')]
  [string]$adminUsername = 't128',
 
  [Parameter(Mandatory = $false, HelpMessage = 'SSH public key')]
  [string]$adminPassword = 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiBpnQGfx9ifcfkOpq0pK6Ax1hPodnrTU/MdomT0cPG39C/6ucr/c8fLQndvpjO0X8XaTypeBcAvgXxVXuF5yGtwjEezPNaRbIRGByDCi1Vat2Xx4qysh+mKT+Dy+zeCdCFi7jVdV9DpCqkOaQo7jcsFREdqz5MdbEYaNw4i6u/6KPkEGhFd9+hzPUEcNDLLwuKx0HXwIywgfxkOt6s7j64Ur7KZ72wpmZNhuFpcAnMOvpFcmJqaff/REnIhVcLHltUWMAtuVInG5lRbxn33+17aJKPsOqIsUcILZOy53F+vmJY8yYZfiJsPbslCKrSTBOfAdefXbc4NXbHWXAQLTEw== rsa-key-20210408'
)

################# Input parameters #################
$deploymentName = '128T-router1'
$armTemplateFile = 'router1.json'
$inputParams = 'init.json'
####################################################

$pathFiles = Split-Path -Parent $PSCommandPath
$templateFile = "$pathFiles\$armTemplateFile"

# reading the input parameter file $inputParams and convert the values in hashtable 
If (Test-Path -Path $pathFiles\$inputParams) {
  # convert the json into PSCustomObject
  $jsonObj = Get-Content -Raw $pathFiles\$inputParams | ConvertFrom-Json
  if ($null -eq $jsonObj) {
    Write-Host "file $inputParams is empty"
    Exit
  }
  # convert the PSCustomObject in hashtable
  if ($jsonObj -is [psobject]) {
    $hash = @{}
    foreach ($property in $jsonObj.PSObject.Properties) {
      $hash[$property.Name] = $property.Value
    }
  }
  foreach ($key in $hash.keys) {
    $message = '{0} = {1} ' -f $key, $hash[$key]
    Write-Output $message
    Try { New-Variable -Name $key -Value $hash[$key] -ErrorAction Stop }
    Catch { Set-Variable -Name $key -Value $hash[$key] }
  }
} 
else { Write-Warning "$inputParams file not found, please change to the directory where these scripts reside ($pathFiles) and ensure this file is present."; Return }

# checking the values of variables
Write-Host "$(Get-Date) - values from file: $inputParams" -ForegroundColor Yellow
if (!$subscriptionName) { Write-Host 'variable $subscriptionName is null' ; Exit }   else { Write-Host '   subscription name.....: '$subscriptionName -ForegroundColor Yellow }
if (!$adminUsername) { Write-Host 'variable $adminUsername is null' ; Exit }         else { Write-Host '   adminUsername.........: '$adminUsername -ForegroundColor Yellow }
if (!$adminRSAKey) { Write-Host 'variable $adminRSAKey is null' ; Exit }             else { Write-Host '   adminRSAKey...........: '$adminRSAKey -ForegroundColor Yellow }
if (!$rgName) { Write-Host 'variable $rgName is null' ; Exit }                       else { Write-Host '   resource group name...: '$rgName -ForegroundColor Yellow }
if (!$locationConductor) { Write-Host 'variable $locationConductor is null' ; Exit } else { Write-Host '   locationConductor.....: '$locationConductor -ForegroundColor Yellow }
if (!$locationRouter1) { Write-Host 'variable $locationRouter1 is null' ; Exit }     else { Write-Host '   locationRouter1.......: '$locationRouter1 -ForegroundColor Yellow }
if (!$locationRouter2) { Write-Host 'variable $locationRouter2 is null' ; Exit }     else { Write-Host '   locationRouter2.......: '$locationRouter2 -ForegroundColor Yellow }
if (!$RGTagExpireDate) { Write-Host 'variable $RGTagExpireDate is null' ; Exit }     else { Write-Host '   RGTagExpireDate.......: '$RGTagExpireDate -ForegroundColor Yellow }
if (!$RGTagContact) { Write-Host 'variable $RGTagContact is null' ; Exit }           else { Write-Host '   RGTagContact..........: '$RGTagContact -ForegroundColor Yellow }
if (!$RGTagNinja) { Write-Host 'variable $RGTagNinja is null' ; Exit }               else { Write-Host '   RGTagNinja............: '$RGTagNinja -ForegroundColor Yellow }
if (!$RGTagUsage) { Write-Host 'variable $RGTagUsage is null' ; Exit }               else { Write-Host '   RGTagUsage............: '$RGTagUsage -ForegroundColor Yellow }

$location = $locationConductor

$parameters = @{
  "adminUsername"      = $adminUsername;
  "adminPublicKeyData" = $adminRSAKey;
  "location"           = $locationRouter1
}

$subscr = Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

# Create Resource Group 
Write-Host "$(Get-Date)-Creating Resource Group $rgName " -ForegroundColor Cyan
Try {
  $rg = Get-AzResourceGroup -Name $rgName  -ErrorAction Stop
  Write-Host '  resource exists, skipping'
}
Catch { $rg = New-AzResourceGroup -Name $rgName  -Location $location }


if ((Get-AzResourceGroup -Name $rgName).Tags -eq $null) {
  # Add Tag Values to the Resource Group
  Set-AzResourceGroup -Name $rgName -Tag @{Expires = $RGTagExpireDate; Contacts = $RGTagContact; Pathfinder = $RGTagNinja; Usage = $RGTagUsage } | Out-Null
}


$runTime = Measure-Command {

  write-host "$(Get-Date)-running ARM template:"$templateFile
  New-AzResourceGroupDeployment  -Name $deploymentName -ResourceGroupName $rgName -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose 
}

write-host "runtime: "$runTime.ToString() -ForegroundColor Yellow
write-host "$(Get-Date)-end deployment" -ForegroundColor Yellow