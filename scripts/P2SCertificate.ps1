# On-Prem VM Post-Deploy Build Script
#
# Configures VM, then downloads and send router config to router
#
# 1. Open Firewall for ICMP
# 2. Test/Create Folders
# 3. Create and push P2S Root cert and pfx
# 4. Pull Config File
# 5. Pull Cert and write to mulitple locations
#



Start-Transcript -Path "C:\P2S_digitalCertificatesCreation.log"

# 1. Open Firewall for ICMP
Write-Host "Opening ICMPv4 Port"
Try {
     Get-NetFirewallRule -Name Allow_ICMPv4_in -ErrorAction Stop | Out-Null
     Write-Host "  Port already open"
}
Catch {
     New-NetFirewallRule -DisplayName "Allow ICMPv4" -Name Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4 | Out-Null
     Write-Host "  Port opened"
}



# 4. Install the PowerShell SDK
Write-Host "Installing Azure PS SDK"
try {
     Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction Stop | Out-Null
     Write-Host "  NuGet already registered, skipping"
}
catch {
     Install-PackageProvider -Name NuGet -Scope AllUsers -MinimumVersion 2.8.5.201 -Force | Out-Null
     Write-Host "  NuGet registered"
}
if ($null -ne (Get-Module Az.Network -ListAvailable)) {
     Write-Host "  Azure SDK already installed, skipping"
}
else {
     Install-Module Az -Scope AllUsers -Force | Out-Null
     Write-Host "  Azure SDK installed"
}

# Connect with the VM's managed identity
Write-Host "Connecting using the VM Managed Identity"
$i = 0
Connect-AzAccount -Identity
$ctx = Get-AzContext
If ($null -eq $ctx.Subscription.Id) {
     Do {
          Write-Host "*"
          Start-Sleep -Seconds 2
          Connect-AzAccount -Identity
          $ctx = Get-AzContext
     }
     Until ($i -gt 15 -or $null -ne $ctx.Subscription.Id)
}
If ($null -eq $ctx.Subscription.Id) { Write-Output "  There is no system-assigned user identity. Aborting."; exit 1 }
Else { Write-Host "  Identity connected" }

# 5. Create and push P2S Root cert and pfx
# Create root cert
Write-Host "Creating P2S root cert"
$certRoot = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=P2SRootCert' }
If ($null -eq $certRoot) {
     $certRoot = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=P2SRootCert" `
          -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 `
          -CertStoreLocation "Cert:\CurrentUser\My" `
          -KeyUsageProperty Sign -KeyUsage CertSign
     Write-Host "  P2S root cert created"
}
Else { Write-Host "  P2S root cert exists, skipping" }

# Create client cert
Write-Host "Creating P2S Client cert"
$certClient = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=P2SChildCert' }
If ($null -eq $certClient) {
     $certClient = New-SelfSignedCertificate -Type Custom -DnsName "P2SChildCert" -KeySpec Signature `
          -KeyExportPolicy Exportable -Subject "CN=P2SChildCert" `
          -HashAlgorithm sha256 -KeyLength 2048 `
          -CertStoreLocation "Cert:\CurrentUser\My"-Signer $certRoot `
          -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
     Write-Host "  P2S Client cert created"
}
Else { Write-Host "  P2S Client cert exists, skipping" }

# Save root certificate to file
Write-Host "Saving root certificate to .cert file"
$FileCert = "C:\P2SRoot.cert"
If (-not (Test-Path -Path $FileCert)) {
     # The private key is not included in the export
     Export-Certificate -Cert $certRoot -FilePath $FileCert | Out-Null
     Write-Host "  root certificate .cert file saved"
}
Else { Write-Host "  root certificate .cert file exists, skipping" }

# Convert to Base64 cer file
Write-Host "Creating root certificate in .cer file"
$FileCer = "C:\P2SRoot.cer"
If (-not (Test-Path -Path $FileCer)) {
     certutil -encode $FileCert $FileCer | Out-Null
     Write-Host "  Created root cer file"
}
Else { Write-Host "  Root cer file exists, skipping" }

# Upload to Key Vault
Write-Host "Uploading root cer file data to Key Vault"
$kvName = (Get-AzKeyVault | Select-Object -First 1).VaultName
Write-Host "kvName: $kvName"
if ($null -eq (Get-AzKeyVaultSecret -VaultName $kvName -Name "P2SRoot")) {
     $cerKey = Get-Content "C:\P2SRoot.cer"
     $certSec = ConvertTo-SecureString $($cerKey[1..($cerKey.IndexOf("-----END CERTIFICATE-----") - 1)] -join ('')) -AsPlainText -Force
     Set-AzKeyVaultSecret -VaultName $kvName -Name "P2SRoot" -SecretValue $certSec | Out-Null
     Write-Host "  Root cer file data saved to Key Vault"
}
else { Write-Host "  Root data already exists in Key Vault, skipping" }


Write-Host "  Creating P2S Client cert password"
$kvs = Get-AzKeyVaultSecret -VaultName $kvName -Name "P2SCertPwd" -ErrorAction Stop 
If ($null -eq $kvs) {
     $pwdP2SCert = ([char[]](Get-Random -Input $(65..90 + 97..122) -Count 8)) -join ""
     # convert $pwdP2SCert to secure string object
     $secPwdP2SCert = ConvertTo-SecureString $pwdP2SCert -AsPlainText -Force
     $kvs = Set-AzKeyVaultSecret -VaultName $kvName -Name "P2SCertPwd" -SecretValue $secPwdP2SCert -ErrorAction Stop
}
Else {
     # fetch the value of password associated with the client certificate from keyvault
     # and assign the value of decrypted password to the variable $pwdP2SCert
     $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($kvs.SecretValue)
     try { $pwdP2SCert = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr) }
     finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr) }
     Write-Host "  P2S Client cert password exists, skipping"
}

# Save Client to file
Write-Host "Exporting client cert to pfx file"
$FilePfx = "C:\Client.pfx"
If (-not (Test-Path -Path $FilePfx)) {
     $secPwdP2SCert = ConvertTo-SecureString $pwdP2SCert -AsPlainText -Force
     #the password used to protect the exported PFX file must be in the form of secure string
     Export-PfxCertificate -Cert $certClient -FilePath $FilePfx  -Password $secPwdP2SCert | Out-Null
     # write password in a file
     Set-Content -Path "C:\ClientSecret.txt" -Value $pwdP2SCert -Force
     Write-Host "  Client cert pfx file created"
}
Else { Write-Host "  Client pfx file exists, skipping" }



# Upload Client to Storage Account 
Write-Host 'Uploading Client.pfx to storage account $web container'
$sa = (Get-AzStorageAccount | Select-Object -First 1)
$saFiles = Get-AzStorageBlob -Container 'certificates' -Context $sa.context
if ($null -ne ($saFiles | Where-Object -Property Name -eq "Client.pfx")) {
     Write-Host "  Client cert exists in Storage Account, skipping"
}
else {
     Set-AzStorageBlobContent -Context $sa.context -Container 'certificates' -File "C:\Client.pfx" -Properties @{"ContentType" = "application/x-pkcs12" } -ErrorAction Stop | Out-Null
     Write-Host "  Client.pfx saved to Storage Account"
}

# Check for the root cert in KeVault
Write-Host "  checking for Root certificate in Key Vault"
$kvs = Get-AzKeyVaultSecret -VaultName $kvName -Name "P2SRoot" -ErrorAction Stop 
If ($null -eq $kvs) {
     Write-Warning "Root certificate data was not written to Key Vault"
     Exit 3
}
# End Nicely
Write-Host "On-Prem VM Build Script Complete"
Stop-Transcript