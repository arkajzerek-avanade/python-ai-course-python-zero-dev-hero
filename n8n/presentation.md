# N8N Workflow Automation Tool - Technical Documentation

## Table of Contents
- [Local Environment Setup](#local-environment-setup)
- [UI Overview and Navigation](#ui-overview-and-navigation)
- [Core Node Types](#core-node-types)
- [Common Triggers](#common-triggers)
- [Managing Credentials](#managing-credentials)
- [Deployment to Azure Container Apps](#deployment-to-azure-container-apps)

## Local Environment Setup

### Prerequisites
- Node.js (v14 or later)
- npm or npx

### Installation
To run n8n locally using npx:

```bash
npx n8n
```

For a more persistent setup:

```bash
# Install n8n globally
npm install -g n8n

# Start the server
n8n start
```

### Configuration Options
You can customize the n8n server by setting environment variables:

```bash
# Set the port
PORT=5678 npx n8n

# Enable tunnel for webhook testing
WEBHOOK_TUNNEL_URL=true npx n8n
```

### Default Access
Once started, n8n is accessible at:
- URL: `http://localhost:5678`
- Default credentials: None (first run will prompt for setup)

## UI Overview and Navigation

### Main Interface Components

1. **Sidebar Navigation**
    - Workflows
    - Templates
    - Credentials
    - Executions
    - Settings

2. **Workflow Canvas**
    - Node placement area
    - Connection lines
    - Execution controls

3. **Node Palette**
    - Search functionality
    - Category filters
    - Recently used nodes

### Workflow Editor Controls

- **Save** - Preserve your workflow
- **Execute** - Run entire workflow
- **Execute Node** - Test individual node
- **Zoom** - Scale canvas view
- **Toggle execution data** - View data between nodes

## Core Node Types

### Data Transformation Nodes
- **Set** - Create/modify variables
- **Function** - Custom JavaScript code
- **IF** - Conditional routing
- **Switch** - Multi-path routing
- **Move Binary Data** - Handle file data

### Integration Nodes
- **HTTP Request** - API interaction
- **Webhook** - Receive external triggers
- **Email** - Send/receive emails
- **Database** - SQL/NoSQL operations

### Utility Nodes
- **Merge** - Combine data streams
- **Split** - Separate data items
- **Wait** - Introduce delays
- **Cron** - Schedule executions

## Common Triggers

### Manual Triggers
- **Execute Workflow** - Run manually
- **Manual Trigger** - Start with custom data

### Automated Triggers
- **Webhook** - HTTP endpoints
- **Cron** - Time-based scheduling
- **Email Trigger** - React to emails
- **Database Trigger** - React to data changes

### Configuration Tips
- Webhook endpoints format: `https://<your-domain>/webhook/<workflow-id>/<node-name>`
- Cron expressions for common schedules:
  - Every hour: `0 * * * *`
  - Daily at midnight: `0 0 * * *`
  - Every Monday: `0 0 * * 1`

## Managing Credentials

### Adding New Credentials
1. Navigate to **Credentials** in the sidebar
2. Click **Create New Credential**
3. Select the service type
4. Complete the required authentication details

### Credential Types
- **API Key** - Simple token authentication
- **OAuth2** - Authorization flow authentication
- **Username/Password** - Basic authentication
- **Certificate** - Client certificate authentication

### Security Best Practices
- Use environment variables for sensitive values
- Regularly rotate API keys
- Set appropriate access scopes for OAuth connections
- Enable encryption at rest for n8n data directory

## Deployment to Azure Container Apps

### Architecture Overview
The deployment uses Azure Container Apps with Azure Storage for persistence to ensure your workflow data is preserved between container restarts.

### Deployment Resources
The infrastructure includes:
- Azure Container App
- Azure Storage Account with File Share
- Log Analytics Workspace
- Container App Environment

### Deployment Process

1. **Clone the Repository**
    ```bash
    git clone <repository-url>
    cd <repository-directory>/n8n/infra
    ```

2. **Review and Customize Parameters**
    - Open `main.bicep` to adjust:
      - Container image version
      - Resource sizing
      - Storage configuration

3. **Deploy Using PowerShell Script**
    ```bash
    ./deploy.ps1
    ```

    This script will:
    - Create or verify resource group existence
    - Deploy all required resources
    - Configure persistent storage
    - Output the deployed application URL

### Configuration Details
The Bicep template (`main.bicep`) provisions:
- Container App with n8n Docker image
- Persistent storage using Azure File Share
- Environment variables for n8n configuration
- External ingress with HTTPS

### Post-Deployment
After deployment, access your n8n instance at the URL shown in the deployment outputs. The first-time setup will walk you through creating an admin account.

### Scaling Considerations
The default configuration deploys a single replica. For production workloads, consider adjusting:
- CPU and memory allocations
- Replica count for high availability
- Storage performance tier