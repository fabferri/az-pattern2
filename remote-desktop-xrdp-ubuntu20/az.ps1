### Run keyvault.ps1 with two numbers:
### the first number is the start-pod-Id 
### the second number is the end-pod-Id
###
###
[CmdletBinding()]
param (
    [Parameter( Mandatory = $false, ValueFromPipeline=$false, HelpMessage='username administrator VMs')]
    [string]$adminUsername = "ADMINISTRATOR_USERNAME",
 
    [Parameter(Mandatory = $false, HelpMessage='password administrator VMs')]
    [string]$adminPassword = "ADMINISTRATOR_PASSWORD"
    )

################# Input parameters #################
$subscriptionName  = "AzureDemo2"     
$location          = "uksouth"
$rgName            = "test8"
$rgDeployment      = "dep01"
$armTemplateFile   = "az.json"
$remotePubIP       = "REMOTE_PUBLIC_IP_TO_ACCESS_TO_THE_VM"+"/32"     #### replace REMOTE_PUBLIC_IP_TO_ACCESS_TO_THE_VM with your public IP
####################################################

$pathFiles      = Split-Path -Parent $PSCommandPath
$templateFile   = "$pathFiles\$armTemplateFile"
$parameters=@{
              "adminUsername"= $adminUsername;
              "adminPassword"= $adminPassword;
              "remotePubIP"=$remotePubIP
              }

$subscr=Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

#Create a resource group
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Creating Resource Group: $rgName " -ForegroundColor Cyan
Try {
    $rg = Get-AzResourceGroup -Name $rgName  -ErrorAction Stop
    Write-Host '  resource exists, skipping'
    }
Catch {
    $rg = New-AzResourceGroup -Name $rgName  -Location $location
    }

$runTime=Measure-Command {
  write-host "ARM template: "$templateFile -ForegroundColor Yellow
  New-AzResourceGroupDeployment  -Name $rgDeployment -ResourceGroupName $rgName -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
}

write-host "runtime: "$runTime.ToString() -ForegroundColor Yellow