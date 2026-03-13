targetScope = 'tenant'

// Subscriptions variables
param billingAccountName string
param billingProfileName string      // ← updated
param invoiceSectionName string      // ← updated
param managementGroupId string 
param managementSubscriptionName string
param Spoke1SubscriptionName string
param Spoke2SubscriptionName string

// param TFstateSubscriptionName string

// Terraform State subscription
// module tfstatesSub '../modules/bicep/subscription.bicep' = {
//   name: 'deploy-tfstates-subscription'
//   params: {
//     subscriptionName: TFstateSubscriptionName
//     billingAccountName: billingAccountName
//     billingProfileName: billingProfileName
//     invoiceSectionName: invoiceSectionName
//     managementGroupId: managementGroupId
//   }
// }

// Management / Hub Subscription
module managementSub '../modules/bicep/subscription.bicep' = {
  name: 'deploy-management-subscription'
  params: {
    subscriptionName: managementSubscriptionName
    billingAccountName: billingAccountName
    billingProfileName: billingProfileName
    invoiceSectionName: invoiceSectionName
    managementGroupId: managementGroupId
  }
}

module Spoke1Sub '../modules/bicep/subscription.bicep' = {
  name: 'deploy-spoke1-subscription'
  params: {
    subscriptionName: Spoke1SubscriptionName
    billingAccountName: billingAccountName
    billingProfileName: billingProfileName
    invoiceSectionName: invoiceSectionName
    managementGroupId: managementGroupId
  }
}

module Spoke2Sub '../modules/bicep/subscription.bicep' = {
  name: 'deploy-spoke2-subscription'
  params: {
    subscriptionName: Spoke2SubscriptionName
    billingAccountName: billingAccountName
    billingProfileName: billingProfileName
    invoiceSectionName: invoiceSectionName
    managementGroupId: managementGroupId
  }
}
