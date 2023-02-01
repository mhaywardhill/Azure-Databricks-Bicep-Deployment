param vnetResourceGroup string

@description('Name of the Azure Databricks workspace to create')
param databricksName string

@description('Managed resource group name')
param managedResourceGroupName string

@description('Name of VNet where Databricks Cluster should be created')
param vnetName string
 
@description('The name of the container Subnet')
param privateSubnetName string

@description('The name of the host Subnet')
param publicSubnetName string

@description('Key Vault location')
param location string = resourceGroup().location

param sku string = 'premium'

@description('Tags')
param tags object = {}

resource databricks 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: databricksName
  location: location
  sku: {
    name: sku
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    publicNetworkAccess: 'Disabled'
    requiredNsgRules: 'NoAzureDatabricksRules'
    parameters: {
      enableNoPublicIp: {
        value: true
      }
      prepareEncryption: {
        value: true
      }
      customPrivateSubnetName: {
        value: privateSubnetName
      }
      customVirtualNetworkId: {
        value: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks', vnetName)
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
    }
  }
  tags: tags
}
