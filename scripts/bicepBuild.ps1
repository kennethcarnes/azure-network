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

# Define the directory containing Bicep files
$bicepDirectory = "./bicep"

# Get all .bicep files in the directory
$bicepFiles = Get-ChildItem -Path $bicepDirectory -Filter *.bicep

foreach ($file in $bicepFiles) {
    Write-Host "Validating $($file.Name)..."
    az bicep build --file $file.FullName
}

Write-Host "Validation completed."
