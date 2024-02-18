# Ensure you have Azure PowerShell module installed and logged in
# Install-Module -Name Az -AllowClobber -Scope CurrentUser
# Connect-AzAccount

$resourceGroup = 'devResourceGroup'

# Fetch all VMs in the resource group
$vms = Get-AzVm -ResourceGroupName $resourceGroup

# Fetch NICs, Public IPs, and VNets
$nics = Get-AzNetworkInterface -ResourceGroupName $resourceGroup
$publicIps = Get-AzPublicIpAddress -ResourceGroupName $resourceGroup
$vnets = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup
$firewalls = Get-AzFirewall -ResourceGroupName $resourceGroup
$bastions = Get-AzBastion -ResourceGroupName $resourceGroup

# Display VMs information
Write-Host "VMs Status:"
$vms | ForEach-Object {
    Write-Host "$($_.Name): PowerState=$($_.PowerState)"
}

# Display NICs information
Write-Host "`nNetwork Interface Cards (NICs):"
$nics | ForEach-Object {
    Write-Host "$($_.Name): IP=$($_.IpConfigurations.PrivateIpAddress)"
}

# Display Public IPs information
Write-Host "`nPublic IPs:"
$publicIps | ForEach-Object {
    Write-Host "$($_.Name): IP=$($_.IpAddress)"
}

# Display VNet information
Write-Host "`nVirtual Networks (VNets):"
$vnets | ForEach-Object {
    Write-Host "$($_.Name): Address Space=$($_.AddressSpace.AddressPrefixes)"
}

# Display Azure Firewall information
Write-Host "`nAzure Firewall Configurations:"
$firewalls | ForEach-Object {
    Write-Host "$($_.Name): IP Configurations=$($_.IpConfigurations.PrivateIpAddress)"
}

# Display Bastion Host information
Write-Host "`nAzure Bastion Hosts:"
$bastions | ForEach-Object {
    Write-Host "$($_.Name): IP=$($_.IpConfigurations.IpAddress)"
}

# Network Connectivity Tests to Public IPs (Example)
# You can use Test-NetConnection for basic connectivity tests to public IPs
Write-Host "`nNetwork Connectivity Tests to Public IPs:"
$publicIps | ForEach-Object {
    $testResult = Test-NetConnection -ComputerName $_.IpAddress -Port 80
    Write-Host "$($_.Name) to $($_.IpAddress): $($testResult.PingSucceeded)"
}

# Note: This script assumes you have the necessary permissions and that your environment is configured for the Azure PowerShell module.
#       Adjust the script as per your specific needs and Azure setup.
