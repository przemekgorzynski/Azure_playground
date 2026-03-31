param vnetName string
param subnetName string
param subnetPrefix string
param privateEndpointNetworkPolicies string
param routeTableId string = '' 

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
    routeTable: empty(routeTableId) ? null : {
      id: routeTableId             // ← only set if provided
    }
  }
}

output subnetId string = subnet.id
