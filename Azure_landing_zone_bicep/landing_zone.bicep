targetScope = 'subscription'

param orgPrefix string
param location string
param regionSh string
param tags object

param ServicePrincipalObjectID string
param RoleDefinitionID string
param principalType string

// param TsStateSubscriptionId string
param MgmntSubscriptionId string
param Spoke1SubscriptionId string
param Spoke2SubscriptionId string

param HubVnetAddressPrefix string
param Spoke1VnetAddressPrefix string
param Spoke2VnetAddressPrefix string

param HubSubnets array
param PrivateDnsZones array
param Spoke1Subnets array
param Spoke2Subnets array


//RG
var RgNameVnetHub     = 'rg-VnetHub-${orgPrefix}-${regionSh}'
var RgNameDnsHub      = 'rg-DnsHub-${orgPrefix}-${regionSh}'
var RgNameVnetSpoke1  = 'rg-VnetSpoke1-${orgPrefix}-${regionSh}'
var RgNameVnetSpoke2  = 'rg-VnetSpoke2-${orgPrefix}-${regionSh}'
// var TfStateRgName     = 'rg-TfState-${orgPrefix}-${regionSh}'

//Vnet
var HubVnetName     = 'vnet-hub-${orgPrefix}-${regionSh}'
var Spoke1VnetName  = 'vnet-spoke1-${orgPrefix}-${regionSh}'
var Spoke2VnetName  = 'vnet-spoke2-${orgPrefix}-${regionSh}'


//////////////////////////////////////////////////////////
/////////////////////////// SP ROLE //////////////////////
//////////////////////////////////////////////////////////

module spRoleAssignmentMgmnt '../modules/bicep/roleAssignment.bicep' = {
  name: 'spRoleAssignment-mgmnt'
  scope: subscription(MgmntSubscriptionId)
  params: {
    principalId: ServicePrincipalObjectID
    roleDefinitionId: RoleDefinitionID
    principalType: principalType
  }
}

module spRoleAssignmentSpoke1 '../modules/bicep/roleAssignment.bicep' = {
  name: 'spRoleAssignment-spoke1'
  scope: subscription(Spoke1SubscriptionId)
  params: {
    principalId: ServicePrincipalObjectID
    roleDefinitionId: RoleDefinitionID
    principalType: principalType
  }
}

module spRoleAssignmentSpoke2 '../modules/bicep/roleAssignment.bicep' = {
  name: 'spRoleAssignment-spoke2'
  scope: subscription(Spoke2SubscriptionId)
  params: {
    principalId: ServicePrincipalObjectID
    roleDefinitionId: RoleDefinitionID
    principalType: principalType
  }
}

//////////////////////////////////////////////////////////
/////////////////////////// HUB //////////////////////////
//////////////////////////////////////////////////////////

// Resource group for vnet
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

module RgHubPrivateDnsZones '../modules/bicep/rg.bicep' = {
  name: 'createResourceGroup-hub-dnz-zones'
  scope: subscription(MgmntSubscriptionId)
  params: {
    rgName: RgNameDnsHub
    rgLocation: location
    tags: {
      Resource: 'Resource Group'
      ...tags
    }
  }
}


// vnet resource
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

// subnets
@batchSize(1)  // 👈 deploy one subnet at a time
module HubSubnet '../modules/bicep/subnet.bicep' = [for s in HubSubnets: {
  name: 'createSubnet-${s.name}'
  scope: resourceGroup(MgmntSubscriptionId, RgNameVnetHub)
  params: {
    vnetName: HubVnetName
    subnetName: s.name
    subnetPrefix: s.prefix
    privateEndpointNetworkPolicies: s.privateEndpointNetworkPolicies
  }
  dependsOn: [
    VnetHub
  ]
}]

module privateDns '../modules/bicep/privateDnsZone.bicep' = [for zone in PrivateDnsZones: {
  name: 'privateDns-${zone.name}'  // unique module name
  scope: resourceGroup(MgmntSubscriptionId, RgNameDnsHub)
  params: {
    zoneName: zone.name
    location: 'global'
    vnetName: VnetHub.outputs.name
    vnetID: VnetHub.outputs.id
    autoDnsRegistration: zone.autoRegistration
    tags: union(tags, {
      Resource: 'Private DNS Zone'
      PrivateZone: zone.name
    })
  }
}]

// DNS Zone link → Spoke1 VNet
module privateDnsLinkSpoke1 '../modules/bicep/privateDnsZoneLink.bicep' = [for zone in PrivateDnsZones: {
  name: 'privateDnsLink-spoke1-${zone.name}'
  scope: resourceGroup(MgmntSubscriptionId, RgNameDnsHub)
  dependsOn: [
    privateDns
    peeringSpoke1ToHub
  ]
  params: {
    zoneName: zone.name
    vnetID: VnetSpoke1.outputs.id
    linkName: 'dns-link-spoke1-${zone.name}'
  }
}]

// DNS Zone link → Spoke2 VNet
module privateDnsLinkSpoke2 '../modules/bicep/privateDnsZoneLink.bicep' = [for zone in PrivateDnsZones: {
  name: 'privateDnsLink-spoke2-${zone.name}'
  scope: resourceGroup(MgmntSubscriptionId, RgNameDnsHub)
  dependsOn: [
    privateDns
    peeringSpoke2ToHub
  ]
  params: {
    zoneName: zone.name
    vnetID: VnetSpoke2.outputs.id
    linkName: 'dns-link-spoke2-${zone.name}'
  }
}]

//////////////////////////////////////////////////////////
/////////////////////// SPOKE 1 //////////////////////////
//////////////////////////////////////////////////////////

// Resource group for vnet
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

// vnet
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

// Route table
module spoke1RouteTable '../modules/bicep/networkRouteTable.bicep' = {
  name: 'createRouteTable-spoke1'
  scope: resourceGroup(Spoke1SubscriptionId, RgNameVnetSpoke1)
  params: {
    routeTableName: 'rt-spoke1-${orgPrefix}-${regionSh}'
    location: location
    tags: tags
    routes: [
      {
        name: 'default'
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'Internet'
      }
      {
        name: 'to-hub'
        addressPrefix: HubVnetAddressPrefix
        nextHopType: 'VnetLocal'
      }
    ]
  }
}

// subnets
@batchSize(1)  // 👈 deploy one subnet at a time
module Spoke1Subnet '../modules/bicep/subnet.bicep' = [for s in Spoke1Subnets: {
  name: 'createSubnet-${s.name}'
  scope: resourceGroup(Spoke1SubscriptionId, RgNameVnetSpoke1)
  params: {
    vnetName: Spoke1VnetName
    subnetName: s.name
    subnetPrefix: s.prefix
    privateEndpointNetworkPolicies: s.privateEndpointNetworkPolicies
    routeTableId: spoke1RouteTable.outputs.id 
  }
  dependsOn: [
    VnetSpoke1
  ]
}]

// Hub → Spoke1 peering
module peeringHubToSpoke1 '../modules/bicep/peering.bicep' = {
  name: 'peering-hub-to-spoke1'
  scope: resourceGroup(MgmntSubscriptionId, RgNameVnetHub)
  dependsOn: [
    VnetHub
    HubSubnet
  ]
  params: {
    localVnetName: HubVnetName
    remoteVnetId: VnetSpoke1.outputs.id
  }
}

// Spoke1 → Hub peering
module peeringSpoke1ToHub '../modules/bicep/peering.bicep' = {
  name: 'peering-spoke1-to-hub'
  scope: resourceGroup(Spoke1SubscriptionId, RgNameVnetSpoke1)
  dependsOn: [
    VnetSpoke1
    Spoke1Subnet
  ]
  params: {
    localVnetName: Spoke1VnetName
    remoteVnetId: VnetHub.outputs.id
  }
}


//////////////////////////////////////////////////////////
/////////////////////// SPOKE 2 //////////////////////////
//////////////////////////////////////////////////////////

// Resource group for vnet
module RgSpoke2Vnet '../modules/bicep/rg.bicep' = {
  name: 'createResourceGroup-spoke2-vnet'
  scope: subscription(Spoke2SubscriptionId)
  params: {
    rgName: RgNameVnetSpoke2
    rgLocation: location
    tags: {
      Resource: 'Resource Group'
      ...tags
    }
  }
}

// vnet
module VnetSpoke2 '../modules/bicep/vnet.bicep' = {
  name: 'createVnet-spoke2'
  scope: resourceGroup(Spoke2SubscriptionId, RgNameVnetSpoke2)
  params: {
    vnetName: Spoke2VnetName
    vnetAddressPrefix: Spoke2VnetAddressPrefix
    location: RgSpoke2Vnet.outputs.location
    tags: {
      Resource: 'Virtual Network'
      ...tags
    }
  }
}

// Route table
module spoke2RouteTable '../modules/bicep/networkRouteTable.bicep' = {
  name: 'createRouteTable-spoke2'
  scope: resourceGroup(Spoke2SubscriptionId, RgNameVnetSpoke2)
  params: {
    routeTableName: 'rt-spoke2-${orgPrefix}-${regionSh}'
    location: location
    tags: tags
    routes: [
      {
        name: 'default'
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'Internet'
      }
      {
        name: 'to-hub'
        addressPrefix: HubVnetAddressPrefix
        nextHopType: 'VnetLocal'
      }
    ]
  }
}

// subnets
@batchSize(1)  // 👈 deploy one subnet at a time
module Spoke2Subnet '../modules/bicep/subnet.bicep' = [for s in Spoke2Subnets: {
  name: 'createSubnet-${s.name}'
  scope: resourceGroup(Spoke2SubscriptionId, RgNameVnetSpoke2)
  params: {
    vnetName: Spoke2VnetName
    subnetName: s.name
    subnetPrefix: s.prefix
    privateEndpointNetworkPolicies: s.privateEndpointNetworkPolicies
    routeTableId: spoke2RouteTable.outputs.id 
  }
  dependsOn: [
    VnetSpoke2
  ]
}]

// Hub → Spoke2 peering
module peeringHubToSpoke2 '../modules/bicep/peering.bicep' = {
  name: 'peering-hub-to-spoke2'
  scope: resourceGroup(MgmntSubscriptionId, RgNameVnetHub)
  dependsOn: [
    VnetHub
    HubSubnet
  ]
  params: {
    localVnetName: HubVnetName
    remoteVnetId: VnetSpoke2.outputs.id
  }
}

// Spoke2 → Hub peering
module peeringSpoke2ToHub '../modules/bicep/peering.bicep' = {
  name: 'peering-spoke2-to-hub'
  scope: resourceGroup(Spoke2SubscriptionId, RgNameVnetSpoke2)
  dependsOn: [
    VnetSpoke2
    Spoke2Subnet
  ]
  params: {
    localVnetName: Spoke2VnetName
    remoteVnetId: VnetHub.outputs.id
  }
}


//////////////////////////
// module TfStateRgModule '../modules/bicep/rg.bicep' = {
//   name: 'createResourceGroup'
//   scope: subscription(TsStateSubscriptionId)  // ← specific sub
//   params: {
//     rgName: TfStateRgName
//     rgLocation: location
//     tags: {
//       Resource: 'Resource Group'
//       ...tags
//     }
//   }
// }
