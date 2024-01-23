param location string = 'eastus'
param hubVnetName string = 'hubVnet'
param spokeVnetDetails array = [
  {
    name: 'spokeVnet1'
    addressPrefix: '10.1.0.0/16'
    subnetPrefix1: '10.1.1.0/24'
    subnetPrefix2: '10.1.2.0/24'
  }
  {
    name: 'spokeVnet2'
    addressPrefix: '10.2.0.0/16'
    subnetPrefix1: '10.2.1.0/24'
    subnetPrefix2: '10.2.2.0/24'
  }
  {
    name: 'spokeVnet3'
    addressPrefix: '10.3.0.0/16'
    subnetPrefix1: '10.3.1.0/24'
    subnetPrefix2: '10.3.2.0/24'
  }
]

module network './network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    hubVnetName: hubVnetName
    spokeVnetDetails: spokeVnetDetails
  }
}

// Outputs can be added as needed
