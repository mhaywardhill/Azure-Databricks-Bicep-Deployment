$date = Get-Date -Format "MM-dd-yyyy"
$deploymentName = "DatabricksDeployment"+"$date"
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName adb-poc-test-rg -TemplateFile .\main.bicep -TemplateParameterFile .\azuredeploy_parameters.json -c