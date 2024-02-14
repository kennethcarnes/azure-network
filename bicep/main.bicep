param location string = 'eastus'
param hubVnetName string = 'hubVnet'
param hubSubnet1Prefix string = '10.0.1.0/24'
param hubSubnet2Prefix string = '10.0.2.0/24'
param spokeVnetDetails array = [
  {
    name: 'spokeVnet1'
    addressPrefix: '10.1.0.0/16'
    subnet1Prefix: '10.1.1.0/24'
    subnet2Prefix: '10.1.2.0/24'
  }
  {
    name: 'spokeVnet2'
    addressPrefix: '10.2.0.0/16'
    subnet1Prefix: '10.2.1.0/24'
    subnet2Prefix: '10.2.2.0/24'
  }
  {
    name: 'spokeVnet3'
    addressPrefix: '10.3.0.0/16'
    subnet1Prefix: '10.3.1.0/24'
    subnet2Prefix: '10.3.2.0/24'
  }
]

module vnets './vnets.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    hubVnetName: hubVnetName
    hubSubnet1Prefix: hubSubnet1Prefix
    hubSubnet2Prefix: hubSubnet2Prefix
    spokeVnetDetails: spokeVnetDetails
  }
}

module firewall './firewall.bicep' = {
  name: 'firewallDeployment'
  params: {
    location: location
    hubVnetName: hubVnetName
    firewallPrivateIp: '10.0.0.4'
  }
  dependsOn: [
    vnets
  ]
}

output hubVnetId string = vnets.outputs.hubVnetId
