param location string
param hubVnetName string
param hubSubnet1Prefix string = '10.0.1.0/24'
param hubSubnet2Prefix string = '10.0.2.0/24'
param spokeVnetDetails array

// Hub Virtual Network
resource hubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet1'
        properties: {
          addressPrefix: hubSubnet1Prefix
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: hubSubnet2Prefix
        }
      }
      // ... other subnets if needed ...
    ]
  }
}

// Spoke Virtual Networks
resource spokeVnets 'Microsoft.Network/virtualNetworks@2021-02-01' = [for (spokeVnetDetail, i) in spokeVnetDetails: {
  name: spokeVnetDetail.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [spokeVnetDetail.addressPrefix]
    }
    subnets: [
      {
        name: 'Subnet1'
        properties: {
          addressPrefix: spokeVnetDetail.subnet1Prefix
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: spokeVnetDetail.subnet2Prefix
        }
      }
    ]
  }
}]

resource vnetPeerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = [for i in range(0, length(spokeVnetDetails)): {
  name: '${spokeVnetDetails[i].name}/peerTo${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    spokeVnets[i]
  ]
}]

// Outputs
output hubVnetId string = hubVnet.id
output workloadSubnetId string = spokeVnets[0].properties.subnets[0].id
