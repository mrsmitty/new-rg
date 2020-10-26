# Connecting Azure to Azure DevOps

## Creating the Azure Resources
The following resources are required to connect Azure to Azure DevOps
- Service Principal: Principal used by Azure DevOps for deployments
- Resource Group: Target for ARM template deployments
- AD Security Group: Used to manage principal role assignments
- Resource Group RBAC: Assigns a role to a group or principal

The script [resourceGroupSecurity.ps1](resourceGroupSecurity.ps1) creates:
- a Resource Group
- Service Principal
- Security Groups (Contributor and Reader) and,
- a Contributor Role Assignments for the Service Principal to the Resource Group

When the script is executed, output similar to the below is provided. Retain this information as it is needed in the next step
```
Subscription ID: 71507755-196c-4337-9af0-109898ee3f0b
Subscription Name: Subscription-Name-Production
Service Principal ID: f67a00bc-c2d8-416e-80dd-5a344f9154d4
Service Principal Key: ***********************************
Service Principal Key: 6c684930-c417-4e78-9d62-b61258e4b619
Service Connection Name: sp-azuredevops-prd-fuelsaver
```

**Note:** The script can be executed multiple times however the service principal key will be changed on each execution. To create a new resource group without refreshing the service principal, run with the `-skipSpCreate` flag.

## Azure DevOps Setup

1. Head to [Azure DevOps](https://dev.azure.com) and sign into your account
2. Within a project, navigate to the project setting (bottom left cog) and create a new service connection
<br/>![NewServiceConnection.png](NewServiceConnection.png)
3. Select "Service principal (manual)
<br/>![ServiceConnectionType.png](ServiceConnectionType.png)
4. Enter the script output
<br/>![ServiceConnectionSettings.png](ServiceConnectionSettings.png)
