# Azure Static Web App deployment script for PowerShell
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

# Variables - update these as needed
$RESOURCE_GROUP = "nameGeneratorRG"
$LOCATION = "eastus"
$APP_NAME = "namegen"
$SKU = "Free"

Write-Log "Starting deployment process for Name Generator Web App"

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
az group create --name $RESOURCE_GROUP --location $LOCATION
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Failed to create resource group"
}

# 3. Create static web app
Write-Log "Creating Azure Static Web App..."
az staticwebapp create `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku $SKU `
    --source . `
    --branch main `
    --output json
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Failed to create static web app"
}

# 4. Deploy the static web app
Write-Log "Deploying content to Azure Static Web App..."
az staticwebapp deploy `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --source .
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
