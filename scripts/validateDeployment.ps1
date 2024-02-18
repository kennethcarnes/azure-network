# PowerShell script for validating Azure Bicep templates

# Ensuring Azure CLI and Bicep are installed
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it from https://aka.ms/installazurecliwindows"
    exit
}

if (-not (Get-Command "bicep" -ErrorAction SilentlyContinue)) {
    Write-Error "Bicep CLI is not installed. Please install it from https://aka.ms/installbicep"
    exit
}

# Validate main.bicep
Write-Host "Validating main.bicep..."
az bicep build --file ./bicep/main.bicep

# Validate firewall.bicep
Write-Host "Validating firewall.bicep..."
az bicep build --file ./bicep/firewall.bicep

# Validate vnets.bicep
Write-Host "Validating firewall.bicep..."
az bicep build --file ./bicep/vnets.bicep

# Validate management.bicep
Write-Host "Validating management.bicep..."
az bicep build --file ./bicep/management.bicep

# Validate compute.bicep
Write-Host "Validating compute.bicep..."
az bicep build --file ./bicep/compute.bicep

Write-Host "Validation completed."
