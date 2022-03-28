# Before running, replace the values: 
#   ADMINISTRATOR_USERNAME
#   ADMINISTRATOR_PASSWORD
# 
# The variable $authenticationType can take two values: "password" OR "sshPublicKey"
#
################# Input parameters #################
$subscriptionName  = "AzDev1"     
$location          = "eastus"
$rgName            = "test-vmss"
$deploymentName    = "vmss"
$armTemplateFile   = "vmss.json"
$adminUsername     = 'ADMINISTRATOR_USERNAME'
$adminPassword     = 'ADMINISTRATOR_PASSWORD'
$authenticationType = "password"
####################################################

$pathFiles      = Split-Path -Parent $PSCommandPath
$templateFile   = "$pathFiles\$armTemplateFile"

$parameters=@{
              "adminUsername"= $adminUsername;
              "adminPasswordOrKey"= $adminPassword;
              "authenticationType" = $authenticationType
              }


$subscr=Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id


Write-Host "$(Get-Date) - Creating Resource Group $rgName " -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $rgName  -ErrorAction Stop
     Write-Host '  resource exists, skipping'}
Catch {$rg = New-AzResourceGroup -Name $rgName  -Location $location  }

$startTime = Get-Date
$runTime=Measure-Command {
   write-host "$startTime - running ARM template:"$templateFile
   New-AzResourceGroupDeployment  -Name $deploymentName -ResourceGroupName $rgName -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose 
}

# End and printout the runtime
$endTime = Get-Date
$TimeDiff = New-TimeSpan $startTime $endTime
$Mins = $TimeDiff.Minutes
$Secs = $TimeDiff.Seconds
$RunTime = '{0:00}:{1:00} (M:S)' -f $Mins, $Secs
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Script completed" -ForegroundColor Green
Write-Host "  Time to complete: $RunTime" -ForegroundColor Yellow