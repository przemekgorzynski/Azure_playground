// modules/bicep/peering.bicep
param localVnetName string
param remoteVnetId string

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${localVnetName}/peering-to-${split(remoteVnetId, '/')[8]}'
  properties: {
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
    allowGatewayTransit: false
  }
}
