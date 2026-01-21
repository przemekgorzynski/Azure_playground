param vnetName string
param subnetName string
param subnetPrefix string
param privateEndpointNetworkPolicies string

// Reference existing VNet
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefix
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
  }
}

output subnetId string = subnet.id
