param location string
param tags object = {}

@description('Web App name')
param webAppName string

@description('App Service Plan name')
param appServicePlanName string

@description('SKU for App Service Plan')
param skuName string = 'P1v3'

resource appPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
  }
  tags: tags
}
