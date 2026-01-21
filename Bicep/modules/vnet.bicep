// This module must be deployed into a resource group
// Pass scope when calling module from main.bicep

param vnetName string
param vnetAddressPrefix string
param location string
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

output id string = vnet.id
output name string = vnet.name
output location string = vnet.location
