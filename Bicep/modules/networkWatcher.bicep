param tags object
param location string
param networkWatcherName string

resource networkWatcher 'Microsoft.Network/networkWatchers@2023-11-01' = {
  name: networkWatcherName
  location: location
  tags: tags
}

output id string = networkWatcher.id
output name string = networkWatcher.name
