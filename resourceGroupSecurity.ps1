<#
.SYNOPSIS Establishes a resource group and credentials for use with Azure DevOps
.DESCRIPTION 
  Creates Service Principal, Resource Group, Security Groups
  Role assignments from Security Groups to Resource Group 
  Assign Service Principal to Contributor Security Group
.PARAMETER spName Name of the service principal
.PARAMETER spName Name of the resource group
.PARAMETER skipSpCreate Skips Service Principal Creation
.EXAMPLE ./resourceGroupSecurity -spName sp-azuredevops-npd-fuelsaver -rgName client-syd-uat-arg-fuelsaver -skipSpCreate
#>


param (
  [Parameter(Mandatory = $true)] [string] $spName,
  [Parameter(Mandatory = $true)] [string] $rgName,
  [Parameter()] [switch] $skipSpCreate
)

if (-Not $skipSpCreate) {
  # Create Service Principal
  Write-Output "Creating Service Principal"
  $sp = az ad sp create-for-rbac -n $spName --skip-assignment --years 1 | ConvertFrom-Json
} else {
  $sp = az ad sp list --filter "displayname eq '$spName'" --query "[0]" | ConvertFrom-Json
}

# Create Resource Groups
Write-Output "Creating Resource Group"
az group create -n $rgName -l australiaeast | ConvertFrom-Json

$readerName = "$rgName-reader"
$contributorName = "$rgName-contributor"

# Create Security Groups
Write-Output "Creating Security Groups"
$contributorGroupId = $(az ad group create --display-name $contributorName --mail-nickname $contributorName --query objectId -o tsv)
$readerGroupId = $(az ad group create --display-name $readerName --mail-nickname $readerName --query objectId -o tsv)

# Security Groups to Resource Group role assignment
Write-Output "Creating Security Group --> Resource Group Role Assignments"
az role assignment create --assignee-principal-type "Group" --role "Contributor" --resource-group $rgName --assignee-object-id $contributorGroupId
az role assignment create --assignee-principal-type "Group" --role "Reader" --resource-group $rgName --assignee-object-id $readerGroupId

Write-Output "Service Principal --> Contributor Security Group"
$spId = $(az ad sp show --id $sp.appId --query objectId -o tsv)
az ad group member add --member-id $spId --group $contributorGroupId

if (-Not $skipSpCreate) {
  $account = az account show | ConvertFrom-Json
  Write-Output "Output for https://dev.azure.com"
  Write-Output "---------------------------------------------"
  Write-Output "Subscription ID: $($account.id)"
  Write-Output "Subscription Name: $($account.name)"
  Write-Output "Service Principal ID: $($sp.appId)"
  Write-Output "Service Principal Key: $($sp.password)"
  Write-Output "Service Principal Key: $($account.tenantId)"
  Write-Output "Service Connection Name: $($sp.displayName)"
  Write-Output "---------------------------------------------"
}