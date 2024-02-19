param location string
param hubVnetName string
param firewallPrivateIp string = '10.0.0.4'

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
  dependsOn: [
    azureFirewall // Ensure firewall is deployed before policy
  ]
}

resource applicationRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
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
  dependsOn: [
    firewallPolicy // Added to ensure policy is in place before rule collections are applied
  ]
}

resource networkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-06-01' = {
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
              '*'
            ]
            destinationAddresses: [
              '8.8.8.8'
              '8.8.4.4'
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
  dependsOn: [
    firewallPolicy // Ensures policy is ready before applying network rules
  ]
}

output firewallPublicIPAddress string = firewallPublicIP.properties.ipAddress
output firewallMgmtPublicIPAddress string = firewallMgmtPublicIP.properties.ipAddress
