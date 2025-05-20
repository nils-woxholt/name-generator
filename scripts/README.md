# Azure Deployment Scripts

This folder contains scripts to deploy the Name Generator website to Azure using Azure Static Web Apps.

## Prerequisites

- Azure CLI installed and configured
- An active Azure subscription
- Git (if deploying from a repository)

## Configuration

Edit the `config.json` file to customize your deployment settings:

```json
{
  "deployment": {
    "resourceGroup": "nameGeneratorRG",  // Name of the resource group
    "location": "eastus",                // Azure region
    "appName": "name-generator-app",     // Name of your app
    "sku": "Free"                        // SKU tier (Free or Standard)
  },
  "app": {
    "source": ".",                       // Source code location
    "branch": "main",                    // Git branch (if applicable)
    "artifactLocation": ""               // Build output directory (if applicable)
  }
}
```

## Deployment Instructions

### Windows (PowerShell)

1. Open PowerShell
2. Navigate to the project root directory
3. Run the deployment script:

```powershell
.\scripts\deploy.ps1
```

### Linux/macOS/WSL (Bash)

1. Open Terminal
2. Navigate to the project root directory
3. Make the script executable:

```bash
chmod +x ./scripts/deploy.sh
```

4. Run the deployment script:

```bash
./scripts/deploy.sh
```

## What the Script Does

1. Checks if you're logged into Azure and prompts for login if needed
2. Creates a resource group if it doesn't exist
3. Creates an Azure Static Web App
4. Deploys your website content to the Static Web App
5. Outputs the URL of your deployed website

## Troubleshooting

If you encounter any issues during deployment:

- Check that you have the latest version of Azure CLI installed
- Ensure you have sufficient permissions in your Azure subscription
- Verify that the configuration parameters in the script match your requirements
- Review the Azure CLI command output for specific error messages
