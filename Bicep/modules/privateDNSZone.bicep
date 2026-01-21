@description('Name of the Private DNS Zone (e.g. privatelink.azuresql.net)')
param zoneName string

@description('Location for the DNS zone (always "global" for Private DNS)')
param location string

param tags  object

param vnetName string

param vnetID string

param autoDnsRegistration bool

resource dnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: zoneName
  location: location
  tags: tags
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: autoDnsRegistration
    virtualNetwork: {
      id: vnetID
    }
  }
}
