targetScope = 'tenant'

param subscriptionName string
param billingAccountName string
param billingProfileName string
param invoiceSectionName string
param managementGroupId string

var billingScope = '/providers/Microsoft.Billing/billingAccounts/${billingAccountName}/billingProfiles/${billingProfileName}/invoiceSections/${invoiceSectionName}'
var mgmntGroup   = '/providers/Microsoft.Management/managementGroups/${managementGroupId}'

resource subscription 'Microsoft.Subscription/aliases@2025-11-01-preview' = {  // ← updated API version
  name: subscriptionName
  properties: {
    workload: 'DevTest'
    displayName: subscriptionName
    billingScope: billingScope
    additionalProperties: {
      managementGroupId: mgmntGroup
    }
  }
}

output subscriptionId string = subscription.properties.subscriptionId
