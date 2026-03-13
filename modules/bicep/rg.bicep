targetScope = 'subscription'

param rgName string
param rgLocation string
param tags object

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: rgLocation
  tags: tags
}

output name string = rg.name
output location string = rg.location
