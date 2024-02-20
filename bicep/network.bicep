param location string = 'eastus'
param hubVnetName string = 'hubVnet'
param hubSubnet1Prefix string = '10.0.1.0/24'
param hubSubnet2Prefix string = '10.0.2.0/24'
param AzureFirewallSubnet string = '10.0.0.0/24'
param AzureFirewallManagementSubnet string = '10.0.3.0/24'
param AzureBastionSubnetPrefix string = '10.0.4.0/27'
param spokeVnetDetails array

var firewallPrivateIp = '10.0.0.4'

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
          routeTable: {
            id: routeTable.id
          }
        }
      }
      {
        name: 'Subnet2'
        properties: {
          addressPrefix: spokeVnetDetail.subnet2Prefix
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}]

// Route Table with a default route through Azure Firewall
resource routeTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${hubVnetName}-routeTable'
  location: location
  properties: {
    routes: [
      {
        name: 'default-route'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
  dependsOn: [
    azureFirewall
  ]
}

resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: '${hubVnetName}-fw-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallMgmtPublicIP 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: '${hubVnetName}-fw-mgmt-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-06-01' = {
  name: '${hubVnetName}-firewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id: firewallPublicIP.id
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'managementConfiguration'
      properties: {
        subnet: {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureFirewallManagementSubnet')
        }
        publicIPAddress: {
          id: firewallMgmtPublicIP.id
        }
      }
    }
  }
  dependsOn: [
    hubVnet
  ]
}
