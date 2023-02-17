param KeyName string
param VaultName string
param keyVersion string

@description('prefix used to name resources')
var prefix = substring(resourceGroup().name, 0, length(resourceGroup().name)-3)

@description('VNET resource group name')
var vnetResourceGroup = '${prefix}-vnet-rg'

@description('Managed resource group name')
var managedResourceGroupName = '${prefix}-mrg'

@description('Name of VNet where Databricks Cluster should be created')
var vnetName = 'vnet-${prefix}'
 
@description('The name of the container Subnet')
param privateSubnetName string

@description('The name of the host Subnet')
param publicSubnetName string

param sku string = 'premium'

@description('Tags')
param tags object = {}

resource databricks 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: prefix
  location: resourceGroup().location
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

    encryption: {
      entities: {
        managedDisk: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyName: KeyName
            keyVaultUri: 'https://${VaultName}.vault.azure.net'
            keyVersion: keyVersion
          }
          rotationToLatestKeyVersionEnabled: true
        }
      }
    }
  }
  tags: tags
}

resource akvaccesspolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: '${VaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: databricks.properties.managedDiskIdentity.principalId
        permissions: {
          keys: [ 'get', 'wrapKey', 'unwrapKey' ]
        }
        tenantId: databricks.properties.managedDiskIdentity.tenantId
      }
    ]
  }
}


