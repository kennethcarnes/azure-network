## Overview
This project automates the deployment of scalable network infrastructure using Azure Bicep and GitHub Actions, featuring a hub and spoke network topology with Azure Firewall for enhanced security.

## Structure

- `.github/workflows/deploy.yml`: CI/CD workflow for deploying resources on Azure.
- `bicep/`: Bicep templates for networking resources.
- `scripts/`: Setup scripts for Azure and GitHub configurations.

## Features

- Hub and spoke network architecture.
- Azure Firewall with predefined security rules.
- Route tables for traffic management.
- (Include Bastion host details here if applicable.)

## Setup Instructions

1. Execute `scripts/setupAzure.ps1` to initialize Azure environment.
2. Add Azure Credential JSON to GitHub Secrets.
3. Generate SSH key pair for remote access to VMs.  `ssh-keygen -t rsa -b 2048` 
4. Run `scripts/setupGithub.ps1` to configure GitHub Secrets and environment variables.
5. Push to main branch to trigger deployment via GitHub Actions.
