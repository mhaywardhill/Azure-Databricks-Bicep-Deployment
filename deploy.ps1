param(
    [string]$ResourceGroupName,
    [string]$KeyName = $(Read-Host "Enter Key Name") ,
    [string]$VaultURI  = $(Read-Host "Enter Vault URI"),
    [string]$keyVersion = $(Read-Host  "Enter Key version")
)

$date = Get-Date -Format "MM-dd-yyyy"
$deploymentName = "DatabricksDeployment"+"$date"
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroupName -KeyName $KeyName -VaultURI $VaultURI -keyVersion $keyVersion -TemplateFile .\main.bicep -TemplateParameterFile .\azuredeploy_parameters.json -c