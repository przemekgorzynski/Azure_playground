param location string
param tags object
param nsgName string
param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

output id string = nsg.id
