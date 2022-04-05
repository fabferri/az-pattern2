$WebResponse = Invoke-WebRequest "https://api.github.com/repos/fabferri/az-pattern/git/trees/master" -Method GET 
$json=$WebResponse.Content

$jsonObj = $json | ConvertFrom-Json



### printout
foreach ($item in $jsonObj.tree)
{
 Write-Host $item.path -ForegroundColor Cyan 
 
}
Write-Host "----------------------------------------" -ForegroundColor Red

$hash = @{}
foreach ($property in $jsonObj.PSObject.Properties) {
    $hash[$property.Name] = $property.Value
} 
$hash.tree.path
