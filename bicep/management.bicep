param location string
param hubVnetName string
param bastionPublicIpName string = '${hubVnetName}-bastion-pip'

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: bastionPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: '${hubVnetName}-bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${hubVnetName}-bastion-config'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}

output bastionPublicIPAddress string = bastionPublicIp.properties.ipAddress
