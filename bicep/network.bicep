param location string
param hubVnetName string
param spokeVnetDetails array

// Generic NSG applicable to all subnets
resource genericNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${hubVnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // Additional rules can be added here
    ]
  }
}

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
        name: 'Subnet1'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: genericNsg.id
          }
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: genericNsg.id
          }
        }
      }
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
          addressPrefix: spokeVnetDetail.subnetPrefix1
          networkSecurityGroup: {
            id: genericNsg.id
          }
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: spokeVnetDetail.subnetPrefix2
          networkSecurityGroup: {
            id: genericNsg.id
          }
        }
      }
    ]
  }
}]

// VNet Peering from each Spoke to the Hub
resource vnetPeerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = [for (spokeVnetDetail, i) in spokeVnetDetails: {
  name: '${spokeVnetDetail.name}/peerTo${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    spokeVnets[i]
  ]
}]

