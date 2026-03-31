targetScope = 'tenant'

param subscriptionName string
param billingAccountName string
param billingProfileName string
param invoiceSectionName string
param managementGroupId string

var billingScope = '/providers/Microsoft.Billing/billingAccounts/${billingAccountName}/billingProfiles/${billingProfileName}/invoiceSections/${invoiceSectionName}'

resource subscription 'Microsoft.Subscription/aliases@2021-10-01' = {
  name: subscriptionName
  properties: {
    workload: 'Production'
    displayName: subscriptionName
    billingScope: billingScope
    additionalProperties: {
      managementGroupId: '/providers/Microsoft.Management/managementGroups/${managementGroupId}'
    }
  }
}

output subscriptionId string = subscription.properties.subscriptionId
