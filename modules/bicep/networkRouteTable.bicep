// modules/bicep/routeTable.bicep
param routeTableName string
param location string
param tags object
param routes array = []

resource routeTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        nextHopType: route.nextHopType
        nextHopIpAddress: route.?nextHopIpAddress  // ← safe access operator
      }
    }]
  }
}

output id string = routeTable.id
output name string = routeTable.name
