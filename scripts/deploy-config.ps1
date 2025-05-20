#!/usr/bin/env pwsh
# Azure Static Web App deployment script using config file
# This script deploys the website to Azure Static Web Apps

# Log function for better readability
function Write-Log {
    param([string]$message)
    Write-Host "[INFO] $message" -ForegroundColor Green
}

# Error handling function
function Write-ErrorLog {
    param([string]$message)
    Write-Host "[ERROR] $message" -ForegroundColor Red
    exit 1
}

# Function to check if a command exists
function Test-CommandExists {
    param([string]$command)
    
    try {
        Get-Command $command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Log "Starting deployment process for Name Generator Web App"

# Check if Azure CLI is installed
if (-not (Test-CommandExists "az")) {
    Write-ErrorLog "Azure CLI is not installed. Please install it first: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
}

# Load configuration from JSON file
$configPath = Join-Path $PSScriptRoot "config.json"
if (-not (Test-Path $configPath)) {
    Write-ErrorLog "Configuration file not found: $configPath"
}

try {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $RESOURCE_GROUP = $config.deployment.resourceGroup
    $LOCATION = $config.deployment.location
    $APP_NAME = $config.deployment.appName
    $SKU = $config.deployment.sku
    $SOURCE = $config.app.source
    $BRANCH = $config.app.branch
    $ARTIFACT_LOCATION = $config.app.artifactLocation
} catch {
    Write-ErrorLog "Failed to parse configuration file: $_"
}

Write-Log "Using configuration:"
Write-Log "  Resource Group: $RESOURCE_GROUP"
Write-Log "  Location: $LOCATION"
Write-Log "  App Name: $APP_NAME"

# 1. Check if logged in to Azure
Write-Log "Checking Azure login status..."
try {
    $null = az account show 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Not logged in. Initiating login process..."
        az login
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorLog "Failed to login to Azure"
        }
    } else {
        $account = az account show | ConvertFrom-Json
        Write-Log "Logged in as: $($account.user.name)"
        Write-Log "Subscription: $($account.name)"
    }
} catch {
    Write-Log "Not logged in. Initiating login process..."
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Failed to login to Azure"
    }
}

# 2. Create resource group if it doesn't exist
Write-Log "Creating resource group if it doesn't exist..."
$groupExists = az group exists --name $RESOURCE_GROUP
if ($groupExists -eq "true") {
    Write-Log "Resource group '$RESOURCE_GROUP' already exists."
} else {
    Write-Log "Creating resource group '$RESOURCE_GROUP'..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Failed to create resource group"
    }
}

# 3. Check if static web app already exists
$appExists = az staticwebapp list --resource-group $RESOURCE_GROUP --query "[?name=='$APP_NAME'].name" -o tsv
if ($appExists) {
    Write-Log "Static Web App '$APP_NAME' already exists. Updating..."
} else {
    # 3. Create static web app
    Write-Log "Creating Azure Static Web App..."
    az staticwebapp create `
        --name $APP_NAME `
        --resource-group $RESOURCE_GROUP `
        --location $LOCATION `
        --sku $SKU `
        --source $SOURCE `
        --branch $BRANCH `
        --app-artifact-location $ARTIFACT_LOCATION `
        --output json
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Failed to create static web app"
    }
}

# 4. Deploy the static web app
Write-Log "Deploying content to Azure Static Web App..."
az staticwebapp deploy `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --source $SOURCE
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Failed to deploy static web app"
}

# 5. Get the URL of the deployed app
$APP_URL = az staticwebapp show `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "defaultHostname" `
    --output tsv

Write-Log "Deployment completed successfully!"
Write-Log "Your website is now available at: https://$APP_URL"
Write-Log "===================="
Write-Log "Name Generator App is now deployed on Azure!"
