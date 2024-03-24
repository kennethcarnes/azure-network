param location string = 'eastus'
param adminUsername string
@secure()
param adminPassword string
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

module network './network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    hubVnetName: 'hubVnet'
    hubSubnet1Prefix: '10.0.1.0/24'
    hubSubnet2Prefix: '10.0.2.0/24'
    AzureFirewallSubnet: '10.0.0.0/24'
    AzureFirewallManagementSubnet: '10.0.3.0/24'
    AzureBastionSubnetPrefix: '10.0.4.0/27'
    spokeVnetDetails: spokeVnetDetails
  }
}

module compute './compute.bicep' = {
  name: 'computeDeployment'
  params: {
    location: location
    vmSize: 'Standard_B1s'
    adminUsername: adminUsername
    adminPassword: adminPassword
    spokeVnetDetails: spokeVnetDetails
  }
  dependsOn: [
    network // Ensure compute resources depend on network resources
  ]
}

module management './bastion.bicep' = {
  name: 'managementDeployment'
  params: {
    location: location
    hubVnetName: 'hubVnet'
  }
  dependsOn: [
    network
  ]
}
