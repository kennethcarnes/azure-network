param location string
param hubVnetName string
param firewallPrivateIp string = '10.0.0.4'
param firewallPublicIPName string = '${hubVnetName}-fw-pip'
param firewallMgmtPublicIPName string = '${hubVnetName}-fw-mgmt-pip'

resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: firewallPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewallMgmtPublicIP 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: firewallMgmtPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-06-01' = {
  name: '${hubVnetName}-firewall'
  location: location
  dependsOn: [
    firewallPublicIP
    firewallMgmtPublicIP
  ]
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
}

resource routeTable 'Microsoft.Network/routeTables@2023-06-01' = {
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
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-06-01' = {
  name: '${hubVnetName}FirewallPolicy'
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource applicationRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-02-01' = {
  parent: firewallPolicy
  name: 'ApplicationRules'
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'Allow-Google'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow-Google'
            ruleType: 'ApplicationRule'
            targetFqdns: [
              'www.google.com'
            ]
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              '*'
            ]
          }
        ]
      }
    ]
  }
}

resource networkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-02-01' = {
  parent: firewallPolicy
  name: 'NetworkRules'
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'DNS-Rules'
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow-DNS'
            ruleType: 'NetworkRule'
            sourceAddresses: [
              '10.0.2.0/24'
            ]
            destinationAddresses: [
              '209.244.0.3'
              '209.244.0.4'
            ]
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            destinationPorts: [
              '53'
            ]
          }
        ]
      }
    ]
  }
}
