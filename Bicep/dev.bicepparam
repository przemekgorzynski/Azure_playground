using 'main.bicep'

param orgPrefix = 'gbay'

param env = 'dev'
param location = 'polandcentral'
param regionSh = 'pl'

param tags = {
  Owner: 'Przemek Gorzynski'
  Env: env
  Organization: 'Gorillabay'
}

param vnetAddressPrefix = '10.0.0.0/16'
param subnets = [
  {
    name: 'subnet-01'
    prefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'subnet-02'
    prefix: '10.0.2.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
  }
]

param nsgSecurityRules = [
  {
    name: 'Allow-SSH'
    properties: {
      priority: 1000
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
]

param PrivateDnsZones = [
  {
    name: 'privatelink.azurewebsites.net'
    autoRegistration: true
  }
  {
    name: '${orgPrefix}.internal'
    autoRegistration: false
  }
]
