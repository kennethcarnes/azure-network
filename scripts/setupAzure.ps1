# PowerShell script for initial Azure setup

# Ensuring Azure CLI is installed
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it from https://aka.ms/installazurecliwindows"
    exit
}

# Login to Azure
Write-Host "Logging into Azure..."
az login --output none

# Input for Subscription ID, Resource Group name, and location
$subscriptionId = Read-Host "Enter your Azure Subscription ID"
$resourceGroupName = "devResourceGroup"
$location = "eastus"

# Set the Azure subscription
az account set --subscription $subscriptionId

# Create a resource group
Write-Host "Creating Resource Group: $resourceGroupName in $location..."
az group create --name $resourceGroupName --location $location --output none

Write-Host "Resource group created successfully."

# Create Azure Service Principal for GitHub Actions
Write-Host "Creating Azure Service Principal for GitHub Actions..."
az ad sp create-for-rbac --name "github-actions-sp" --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName