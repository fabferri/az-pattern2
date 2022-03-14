#
################# Input parameters #################
$subscriptionName = 'AzDev'
$deploymentName = 'az-fw2'
$armTemplateFile = 'az.json'
$location = 'uksouth'
$rgName = 'az-fw-poc6'
$adminUsername = 'ADMINISTRATOR_USERNAME'
$adminPasswordOrKey= 'RSA_PUBLIC_KEY'
####################################################

$pathFiles = Split-Path -Parent $PSCommandPath
$templateFile = "$pathFiles\$armTemplateFile"

$subscr=Get-AzSubscription -SubscriptionName $subscriptionName
Select-AzSubscription -SubscriptionId $subscr.Id

# Login Check
Try {Write-Host 'Using Subscription: ' -NoNewline
     Write-Host $((Get-AzContext).Name) -ForegroundColor Green}
Catch {
    Write-Warning 'You are not logged in dummy. Login and try again!'
    Return}


$parameters=@{
              "adminUsername" = $adminUsername;
              "adminPasswordOrKey" = $adminPasswordOrKey;
              "location" = $location
              }


# Create Resource Group
Write-Host "$(Get-Date) - Creating Resource Group" -ForegroundColor Cyan
Try {$rg = Get-AzResourceGroup -Name $rgName -ErrorAction Stop
     Write-Host 'Resource exists, skipping'}
Catch {$rg = New-AzResourceGroup -Name $rgName -Location $location}


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





