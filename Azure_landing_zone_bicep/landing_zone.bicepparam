using 'landing_zone.bicep'

param location = 'westeurope'
param regionSh = 'we'
param orgPrefix = 'internal'

param tags = {
  Owner: 'Przemek Gorzynski'
  environment: 'dev'
  purpose: 'landing_zone'
  createdBy: 'bicep'
}

param ServicePrincipalObjectID  = '5574f1c9-00d5-443c-aed1-a24ed2a017a0'
param RoleDefinitionID          = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //Owner
param principalType             = 'ServicePrincipal'

// b24988ac-6180-42a0-ab88-20f7382dd24c Contributor


// Subscriptions
// param TsStateSubscriptionId = 'ba1161d8-2a27-4a39-b71b-b1f52da5b493'
param MgmntSubscriptionId   = '498ff788-a1a1-4860-a97f-3ee90d4fab61'
param Spoke1SubscriptionId  = '4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720'
param Spoke2SubscriptionId  = 'fa2293f5-402a-453a-a8da-0870c83a6122'

// Mgmnt Subscription
param HubVnetAddressPrefix  = '10.0.0.0/16'
param HubSubnets = [
  {
    name: 'Hub-mgmnt-subnet'
    prefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'Hub-pe-subnet'
    prefix: '10.0.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
]

param PrivateDnsZones = [
  {
    name: 'privatelink.blob.core.windows.net'
    autoRegistration: false
  }
]


// Spoke 1 Subscription
param Spoke1VnetAddressPrefix  = '10.1.0.0/16'
param Spoke1Subnets = [
  {
    name: 'subnet-01'
    prefix: '10.1.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'subnet-02'
    prefix: '10.1.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
]

// Spoke 2 Subscription
param Spoke2VnetAddressPrefix  = '10.2.0.0/16'
param Spoke2Subnets = [
  {
    name: 'subnet-01'
    prefix: '10.2.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    name: 'subnet-02'
    prefix: '10.2.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
]
