# PowerShell script to automate GitHub secrets and environment variables setup

# Ensure GitHub CLI is installed
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI is not installed. Please install it from https://cli.github.com/"
    exit
}

# GitHub repository details
$repositoryOwner = Read-Host "Enter the GitHub repository owner (username or organization)"
$repositoryName = Read-Host "Enter the GitHub repository name"

# Environment variable keys
$envVarKeys = @(
    "RESOURCE_GROUP_NAME",
    "LOCATION",
    "ADMIN_PASSWORD"
)
# Prompt for each environment variable
foreach ($key in $envVarKeys) {
    $value = Read-Host "Enter the value for $key"
    gh secret set $key --body $value --repo "$repositoryOwner/$repositoryName"
}

Write-Host "GitHub repository secrets and environment variables have been set."
