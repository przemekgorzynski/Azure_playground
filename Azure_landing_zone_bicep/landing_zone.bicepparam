using 'landing_zone.bicep'

param location = 'polandcentral'
param regionSh = 'pl'
param orgPrefix = 'company'

param tags = {
  Owner: 'Przemek Gorzynski'
  environment: 'platform'
  purpose: 'management'
  createdBy: 'bicep'
}

// Subscriptions
param MgmntSubscriptionId   = '498ff788-a1a1-4860-a97f-3ee90d4fab61'
param TsStateSubscriptionId = 'ba1161d8-2a27-4a39-b71b-b1f52da5b493'
param Spoke1SubscriptionId  = '4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720'

// Mgmnt Subscription
param HubVnetAddressPrefix  = '10.0.0.0/16'



// Spoke 1 Subscription
param Spoke1VnetAddressPrefix  = '10.1.0.0/16'
