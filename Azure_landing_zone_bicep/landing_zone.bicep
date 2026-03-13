targetScope = 'subscription'

param orgPrefix string
param location string
param regionSh string
param tags object
param MgmntSubscriptionId string
param TsStateSubscriptionId string
param Spoke1SubscriptionId string

param HubVnetAddressPrefix string
param Spoke1VnetAddressPrefix string

//RG
var RgNameVnetHub     = 'rg-VnetHub-${orgPrefix}-${regionSh}'
var RgNameVnetSpoke1  = 'rg-VnetSpoke1-${orgPrefix}-${regionSh}'
var TfStateRgName     = 'rg-TfState-${orgPrefix}-${regionSh}'

//Vnet
var HubVnetName     = 'vnet-hub-${orgPrefix}-${regionSh}'
var Spoke1VnetName  = 'vnet-spoke1-${orgPrefix}-${regionSh}'

//////////////////////////
module RgHubVnet '../modules/bicep/rg.bicep' = {
  name: 'createResourceGroup-hub-vnet'
  scope: subscription(MgmntSubscriptionId)
  params: {
    rgName: RgNameVnetHub
    rgLocation: location
    tags: {
      Resource: 'Resource Group'
      ...tags
    }
  }
}

module VnetHub '../modules/bicep/vnet.bicep' = {
  name: 'createVnet-hub'
  scope: resourceGroup(MgmntSubscriptionId, RgNameVnetHub)
  params: {
    vnetName: HubVnetName
    vnetAddressPrefix: HubVnetAddressPrefix
    location: RgHubVnet.outputs.location
    tags: {
      Resource: 'Virtual Network'
      ...tags
    }
  }
}
//////////////////////////
module RgSpoke1Vnet '../modules/bicep/rg.bicep' = {
  name: 'createResourceGroup-spoke1-vnet'
  scope: subscription(Spoke1SubscriptionId)
  params: {
    rgName: RgNameVnetSpoke1
    rgLocation: location
    tags: {
      Resource: 'Resource Group'
      ...tags
    }
  }
}

module VnetSpoke1 '../modules/bicep/vnet.bicep' = {
  name: 'createVnet-spoke1'
  scope: resourceGroup(Spoke1SubscriptionId, RgNameVnetSpoke1)
  params: {
    vnetName: Spoke1VnetName
    vnetAddressPrefix: Spoke1VnetAddressPrefix
    location: RgSpoke1Vnet.outputs.location
    tags: {
      Resource: 'Virtual Network'
      ...tags
    }
  }
}

////////////////////////// Peetring HUB vnet and spoke vnet
// Hub → Spoke1
module peeringHubToSpoke1 '../modules/bicep/peering.bicep' = {
  name: 'peering-hub-to-spoke1'
  scope: resourceGroup(MgmntSubscriptionId, RgNameVnetHub)
  dependsOn: [VnetHub]
  params: {
    localVnetName: HubVnetName
    remoteVnetId: VnetSpoke1.outputs.id
  }
}

// Spoke1 → Hub
module peeringSpoke1ToHub '../modules/bicep/peering.bicep' = {
  name: 'peering-spoke1-to-hub'
  scope: resourceGroup(Spoke1SubscriptionId, RgNameVnetSpoke1)
  dependsOn: [VnetSpoke1]
  params: {
    localVnetName: Spoke1VnetName
    remoteVnetId: VnetHub.outputs.id
  }
}

//////////////////////////
module TfStateRgModule '../modules/bicep/rg.bicep' = {
  name: 'createResourceGroup'
  scope: subscription(TsStateSubscriptionId)  // ← specific sub
  params: {
    rgName: TfStateRgName
    rgLocation: location
    tags: {
      Resource: 'Resource Group'
      ...tags
    }
  }
}
