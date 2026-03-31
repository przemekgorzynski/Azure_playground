targetScope = 'subscription'

param tags object

resource applyTags 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  properties: {
    tags: tags
  }
}
