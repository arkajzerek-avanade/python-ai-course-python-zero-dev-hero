#!/bin/bash
# Azure resource deployment script with auto-generated credentials

# Set workload name and resource group
export WORKLOAD_NAME="python-ai-sandbox"
export RESOURCE_GROUP="rg-${WORKLOAD_NAME}"

# Generate random admin username and password
export ADMINUSER="admin$(shuf -i 100000-999999 -n 1)"

# Generate complex password (16 chars with uppercase, lowercase, numbers, and special chars)
export ADMINPASS=$(LC_ALL=C tr -dc 'a-zA-Z0-9!@#$%^&*()-_=+[]{};:,.<>?' < /dev/urandom | head -c 16)

# Save credentials to .env file for later reference
cat > .env << EOL
WORKLOAD_NAME=${WORKLOAD_NAME}
RESOURCE_GROUP=${RESOURCE_GROUP}
ADMINUSER=${ADMINUSER}
ADMINPASS=${ADMINPASS}
EOL

# Create resource group and deploy
az group create --name $RESOURCE_GROUP --location westeurope
az deployment group what-if --resource-group $RESOURCE_GROUP --template-file main.bicep
az deployment group create --resource-group $RESOURCE_GROUP --template-file main.bicep --parameters workloadName=$WORKLOAD_NAME adminUsername=$ADMINUSER adminPassword=$ADMINPASS

echo "Deployment completed. Credentials saved to .env file."
