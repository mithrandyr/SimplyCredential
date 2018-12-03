function Get-AzureToken {
    param([Parameter()][ValidateSet("DataLake","EventHubs","KeyVault","ResourceManager","ServiceBus","Sql","Storage")]
        [string]$ResourceName = "ResourceManager"
        , [Parameter()][string]$ApiVersion = "2018-02-01"
        , [switch]$AsToken)

    $resourceIds = @{
        ResourceManager = "https://management.azure.com/"
        KeyVault = "https://vault.azure.net/"
        DataLake = "https://datalake.azure.net/"
        Sql = "https://database.windows.net/"
        EventHubs = "https://eventhubs.azure.net/"
        ServiceBus = "https://servicebus.azure.net/"
        Storage = "https://storage.azure.com/"
    }

    [string]$Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version={0}&resource={1}" -f $ApiVersion, $resourceIds[$ResourceName]

    if($AsToken) {
        Invoke-RestMethod -Uri $Uri -ContentType "application/json" -Method Get -Headers @{Metadata=$true} |
            Select-Object -ExpandProperty access_token
    }
    else { Invoke-RestMethod -Uri $Uri -ContentType "application/json" -Method Get -Headers @{Metadata=$true} }
}

Export-ModuleMember -Function Get-AzureToken

<#
Managed Service Resource Ids
https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-msi

Using PowerShell for MSI
https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-use-vm-token#get-a-token-using-azure-powershell

Use Case: accessing Azure Storage
https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-vm-windows-access-storage
https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad-script

grabbing list of blobs
$data = invoke-restmethod -uri "https://ga811.blob.core.windows.net/geocall-deploy-configuration?restype=container&comp=list" -Headers @{Authorization = "bearer $token"; "x-ms-version" = "2017-11-09"} -UseBasicParsing ; $data = [xml]($data.substring(3))

#>