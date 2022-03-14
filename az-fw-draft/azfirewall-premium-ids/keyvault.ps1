$objUser=Get-AzADUser -UserPrincipalName user1@contoso.com

$kvName= 'fw-quick-asqxpxtommoho'
$rgName= 'az-fw-poc100'
Get-AzKeyVault -VaultName $kvName -ResourceGroupName $rgName

#Set-AzKeyVaultAccessPolicy -VaultName $kvName -ResourceGroupName $rgName -ObjectId $objUser.id -PermissionsToCertificates get,list
Set-AzKeyVaultAccessPolicy -VaultName $kvName -ResourceGroupName $rgName -ObjectId $objUser.id -PermissionsToSecrets get,list