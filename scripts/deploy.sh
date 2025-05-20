#!/bin/bash
# Azure Static Web App deployment script
# This script deploys the website to Azure Static Web Apps

# Log function for better readability
log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

# Error handling function
handle_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
    exit 1
}

# Variables - update these as needed
RESOURCE_GROUP="nameGeneratorRG"
LOCATION="eastus"
APP_NAME="name-generator-app"
SKU="Free"

log "Starting deployment process for Name Generator Web App"

# 1. Check if logged in to Azure
log "Checking Azure login status..."
az account show &> /dev/null || { 
    log "Not logged in. Initiating login process..."
    az login || handle_error "Failed to login to Azure"
}

# 2. Create resource group if it doesn't exist
log "Creating resource group if it doesn't exist..."
az group create --name $RESOURCE_GROUP --location $LOCATION || handle_error "Failed to create resource group"

# 3. Create static web app
log "Creating Azure Static Web App..."
az staticwebapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku $SKU \
    --source . \
    --branch main \
    --app-artifact-location "" \
    --output json || handle_error "Failed to create static web app"

# 4. Deploy the static web app
log "Deploying content to Azure Static Web App..."
az staticwebapp deploy \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --source . || handle_error "Failed to deploy static web app"

# 5. Get the URL of the deployed app
APP_URL=$(az staticwebapp show \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "defaultHostname" \
    --output tsv)

log "Deployment completed successfully!"
log "Your website is now available at: https://$APP_URL"
