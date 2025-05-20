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
$LOCATION = "westeurope"
$APP_NAME = "namegen"
$SKU = "Free"
$REPO_URL = "https://github.com/nils-woxholt/name-generator"
$REPO_BRANCH = "main"
$GITHUB_TOKEN = $null

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

# 1.5 List available subscriptions and let user select one
Write-Log "Available Azure subscriptions:"
az account list --output table
$subscription = Read-Host "Enter the subscription ID or name you want to use (press Enter to use the default)"
if ($subscription) {
    Write-Log "Setting subscription to: $subscription"
    az account set --subscription $subscription
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Failed to set subscription"
    }
}

# 2. Create resource group if it doesn't exist
Write-Log "Creating resource group if it doesn't exist..."
az group create --name $RESOURCE_GROUP --location $LOCATION
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Failed to create resource group"
}

# Before the staticwebapp create command
if (-not $GITHUB_TOKEN) {
    Write-Log "GitHub authentication is required for deploying from a GitHub repository"
    Write-Log "You can either:"
    Write-Log "1. Create a Personal Access Token at https://github.com/settings/tokens"
    Write-Log "2. Or use the --login-with-github flag with the Azure CLI"
    
    $useLoginFlag = Read-Host "Would you like to use the --login-with-github flag? (y/n)"
    
    if ($useLoginFlag -eq "y") {
        # Add the --login-with-github flag to the staticwebapp create command
        $githubAuthFlag = "--login-with-github"
    } else {
        $GITHUB_TOKEN = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
        $githubAuthFlag = "--token (ConvertFrom-SecureString -SecureString $GITHUB_TOKEN -AsPlainText)"
    }
}

# 3. Create static web app from GitHub repository
Write-Log "Creating Azure Static Web App from GitHub repository..."
az staticwebapp create `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku $SKU `
    --source $REPO_URL `
    --branch $REPO_BRANCH `
    $githubAuthFlag `
    --output json
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Failed to create static web app"
}

# 4. Get the URL of the deployed app
$APP_URL = az staticwebapp show `
    --name $APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "defaultHostname" `
    --output tsv

Write-Log "Deployment initiated successfully!"
Write-Log "Once the GitHub workflow completes, your website will be available at: https://$APP_URL"
Write-Log "Note: The actual deployment is now handled by GitHub Actions. Check the Actions tab in the repository for deployment status."
