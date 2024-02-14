param location string
param hubVnetName string
param hubSubnet1Prefix string = '10.0.1.0/24'
param hubSubnet2Prefix string = '10.0.2.0/24'
param spokeVnetDetails array
param AzureFirewallSubnet string = '10.0.0.0/24'
param AzureFirewallManagementSubnetPrefix string = '10.0.0.64/26' // Example subnet prefix for management

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
        name: 'AzureFirewallManagementSubnet' // Define the management subnet
        properties: {
          addressPrefix: AzureFirewallManagementSubnetPrefix
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
