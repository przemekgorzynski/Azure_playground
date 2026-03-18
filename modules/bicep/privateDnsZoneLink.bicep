// modules/bicep/privateDnsZoneLink.bicep

param zoneName string
param vnetID string
param linkName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: zoneName
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: linkName
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetID
    }
    registrationEnabled: false
  }
}

output id string = vnetLink.id
output name string = vnetLink.name
