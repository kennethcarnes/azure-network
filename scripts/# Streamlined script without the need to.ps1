# Ensure Azure context is set
Connect-AzAccount

$resourceGroup = "devResourceGroup"

# Fetch resources
$vmList = Get-AzVm -ResourceGroupName $resourceGroup
$nicList = Get-AzNetworkInterface -ResourceGroupName $resourceGroup
$publicIpList = Get-AzPublicIpAddress -ResourceGroupName $resourceGroup
$vnetList = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup
$bastion = Get-AzBastion -ResourceGroupName $resourceGroup | Where-Object { $_.Name -eq "hubVnet-bastion" }

# Function to test connectivity using Bastion
Function Test-SSHConnectivity {
    param (
        [Parameter(Mandatory=$true)]
        [string]$vmName,
        [string]$resourceGroupName = $resourceGroup
    )
    $vm = Get-AzVm -Name $vmName -ResourceGroupName $resourceGroupName
    if ($vm -eq $null) {
        Write-Host "VM $vmName not found."
        return
    }
    $bastionHost = $bastion.DnsName
    Write-Host "Testing SSH Connectivity to $vmName through Bastion Host $bastionHost..."
    # Note: Actual SSH command execution would require interactive session or SSH key configuration
}

# Validate VMs and Test SSH Connectivity
foreach ($vm in $vmList) {
    Write-Host "Validating VM: $($vm.Name)"
    Test-SSHConnectivity -vmName $vm.Name
}

# Network and Application Testing
# Assuming VMs are Linux based for using SSH and ping
# Note: For Windows VMs, consider using WinRM or other remote management tools

# Test Network Connectivity (Ping) and Application Access
# This part would ideally be executed within the SSH session initiated above, which requires manual interaction or a custom automation setup
# For automated tests, consider deploying a custom script on the VM that performs these tests and reports back

# Display Public IP Addresses for manual external access testing
Write-Host "`nPublic IP Addresses:"
$publicIpList | ForEach-Object {
    Write-Host "$($_.Name): $($_.IpAddress)"
}

# Instructions for Manual Testing
Write-Host "`nPlease manually test SSH connectivity through Azure Bastion using the public DNS name of the bastion host."
Write-Host "For internal connectivity tests (ping, curl) between VMs, execute these commands within each VM's SSH session."

# Note: The limitations of PowerShell scripting for interactive SSH sessions and the security context of Azure mean some steps, particularly those involving SSH into VMs, require manual actions or the use of third-party tools like sshpass for automation, which is not recommended for secure environments.
