# Azure resource deployment script with auto-generated credentials

# Set workload name and resource group
$env:WORKLOAD_NAME = 'pythonai'
$env:RESOURCE_GROUP = 'rg-' + $env:WORKLOAD_NAME

# Generate random admin username and password
$env:ADMINUSER = "admin" + (Get-Random -Minimum 100000 -Maximum 999999)

# Generate complex password (16 chars with uppercase, lowercase, numbers, and special chars)
# Ensure minimum 12 characters as required by the template
$passwordLength = 16
$charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
$securePassword = -join ((1..$passwordLength) | ForEach-Object { $charSet[(Get-Random -Minimum 0 -Maximum $charSet.Length)] })

# Add validation to ensure password meets complexity requirements
$hasLower = $securePassword -cmatch "[a-z]"
$hasUpper = $securePassword -cmatch "[A-Z]" 
$hasDigit = $securePassword -cmatch "\d"
$hasSpecial = $securePassword -cmatch "[^a-zA-Z0-9]"

if (-not ($hasLower -and $hasUpper -and $hasDigit -and $hasSpecial) -or $securePassword.Length -lt 12) {
    Write-Warning "Generated password doesn't meet complexity requirements. Regenerating..."
    # Ensure at least one of each required character type
    $securePassword = `
        (Get-Random -InputObject "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()) + `
        (Get-Random -InputObject "abcdefghijklmnopqrstuvwxyz".ToCharArray()) + `
        (Get-Random -InputObject "0123456789".ToCharArray()) + `
        (Get-Random -InputObject "!@#$%^&*".ToCharArray())
    
    # Fill remaining length with random characters
    $remainingLength = $passwordLength - 4
    $securePassword += -join ((1..$remainingLength) | ForEach-Object { $charSet[(Get-Random -Minimum 0 -Maximum $charSet.Length)] })
    
    # Shuffle the password characters
    $securePassword = -join ($securePassword.ToCharArray() | Get-Random -Count $securePassword.Length)
}

$env:ADMINPASS = $securePassword

# Save credentials to .env file for later reference
@"
WORKLOAD_NAME=$env:WORKLOAD_NAME
RESOURCE_GROUP=$env:RESOURCE_GROUP
ADMINUSER=$env:ADMINUSER
ADMINPASS=$env:ADMINPASS
"@ | Out-File -FilePath ".\.env" -Encoding utf8

# Create resource group and deploy
az group create --name $env:RESOURCE_GROUP --location westeurope

# Run deployment with validated parameters
Write-Host "Starting deployment with safe parameter values..."
az deployment group what-if --resource-group $env:RESOURCE_GROUP --template-file main.bicep --parameters workloadName=$env:WORKLOAD_NAME adminUsername=$env:ADMINUSER adminPassword=$env:ADMINPASS
az deployment group create --resource-group $env:RESOURCE_GROUP --template-file main.bicep --parameters workloadName=$env:WORKLOAD_NAME adminUsername=$env:ADMINUSER adminPassword=$env:ADMINPASS

# Display connection information
Write-Host "Deployment completed. Credentials saved to .env file."
Write-Host "You can connect to the VM using: admin username=$env:ADMINUSER, password is in the .env file"
