param location string
param hubVnetName string = 'hubVnet'
param hubSubnet1Prefix string = '10.0.1.0/24'
param hubSubnet2Prefix string = '10.0.2.0/24'
param spokeVnetDetails array
param AzureFirewallSubnet string = '10.0.0.0/24'
param AzureFirewallManagementSubnet string = '10.0.3.0/24'
param AzureBastionSubnetPrefix string = '10.0.4.0/27' // Ensure this prefix doesn't overlap with other subnet ranges

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
          addressPrefix: AzureFirewallSubnet
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: AzureFirewallManagementSubnet
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
      // Define the AzureBastionSubnet required for the Bastion Host
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: AzureBastionSubnetPrefix
        }
      }
    ]
  }
}

resource spokeVnets 'Microsoft.Network/virtualNetworks@2021-02-01' = [for spokeVnetDetail in spokeVnetDetails: {
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

resource vnetPeerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = [for (spokeVnetDetail, i) in spokeVnetDetails: {
  name: '${spokeVnetDetail.name}/peerTo${hubVnetName}'
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

output hubVnetId string = hubVnet.id
