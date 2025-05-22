# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# --- Configuration ---
$ResourceGroupName = "n8n"
$Location = "westeurope" # Choose an appropriate Azure region
$BicepFile = "main.bicep"
$DeploymentName = "n8n-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')" # Unique deployment name

# --- Script Logic ---

Write-Host "Checking if resource group '$ResourceGroupName' exists in location '$Location'..."

# Check if the resource group exists
$resourceGroupExists = az group exists --resource-group $ResourceGroupName | ConvertFrom-Json
if (-not $resourceGroupExists) {
    Write-Host "Resource group '$ResourceGroupName' does not exist. Creating..."
    az group create --name $ResourceGroupName --location $Location --output table | Out-Null
    Write-Host "Resource group '$ResourceGroupName' created successfully."
} else {
    Write-Host "Resource group '$ResourceGroupName' already exists."
}

Write-Host "Starting Bicep deployment '$DeploymentName' to resource group '$ResourceGroupName'..."

# Deploy the Bicep template
az deployment group create `
    --name $DeploymentName `
    --resource-group $ResourceGroupName `
    --template-file $BicepFile `
    --parameters location=$Location `
    --output table | Out-Null

Write-Host "Deployment '$DeploymentName' completed successfully."

# Optional: Display outputs from the deployment
Write-Host "Fetching deployment outputs..."
az deployment group show `
    --name $DeploymentName `
    --resource-group $ResourceGroupName `
    --query properties.outputs `
    --output table