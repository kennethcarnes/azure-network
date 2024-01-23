# Virtual Network Peering Deployment

[![Azure Deployment](https://github.com/kennethcarnes/az-700/actions/workflows/deploy.yml/badge.svg)](https://github.com/kennethcarnes/az-700/actions/workflows/deploy.yml)

## Overview
This project automates deployment for resources using Azure Bicep and GitHub Actions.
- Virtual Networks: Two VNets (vnet1, vnet2) with subnet and NSG configurations.
- Virtual Machines: Two VMs in separate subnets for network testing.
- Modularity: compute.bicep for compute resources, network.bicep for networking.

## Structure

- `.github/workflows/deploy.yml`: CI/CD workflow for deploying resources.
- `bicep/`: Bicep templates for Azure network resources and VM configuration.
- `scripts/`: Scripts for setting up Azure and GitHub configurations.

## Setup Instructions

1. Run the `scripts/setupAzure.ps1` script to set up the Azure resource group and service principal.
2. Add the Azure Credential JSON to Github Secrets.
3. Run the `scripts/setupGithub.ps1` script to configure other GitHub Secrets.
4. Push changes to trigger the GitHub Actions workflow for deployment.
