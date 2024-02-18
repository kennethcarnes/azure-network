# Streamlined verification script without defining multiple variables

# List all resources in the resource group 'devResourceGroup'
az resource list --resource-group devResourceGroup --output table

# Verify Virtual Networks and Subnets
az network vnet list --resource-group devResourceGroup --output table

# Check Virtual Machines
az vm list --resource-group devResourceGroup --show-details --output table

# Verify Network Interface Cards
az network nic list --resource-group devResourceGroup --output table

# Check Public IP Addresses
az network public-ip list --resource-group devResourceGroup --output table

# Inspect Azure Firewall Configuration
az network firewall show --name hubVnet-firewall --resource-group devResourceGroup --output json

# Inspect Bastion Host
az network bastion show --name hubVnet-bastion --resource-group devResourceGroup --output json