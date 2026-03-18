// modules/roleAssignment.bicep

targetScope = 'subscription'

@description('The principal ID of the service principal')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

param principalType string

var roleAssignmentName = guid(subscription().id, principalId, roleDefinitionId)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

output roleAssignmentId string = roleAssignment.id
