<#
.Synopsis
    Get Token for accessing Azure Resources.

.Description
    Get Token for accessing Azure Resources.
    This token is either from the Identity Management Service (IMS)
    that Azure VMs and other Azure services use.  Or it is the token generated
    from the user credentials (username/password) that is passed in.  If using
    credentials, requires the Az.Accounts PowerShell module to be loaded.

    Using the switch -AzProfile will attempt to pull the token from the cache
    but requires that you already have the module loaded and are authenticated.

.Parameter ResourceName
    The resource you wish a token for.

.Parameter ApiVersion
    [IMS] The API version you are accessing, defaults to '2018-02-01'

.Parameter AsToken
    [IMS] Will only return the token instead of the entire entire response.

.Parameter AzUserCredential
    The credentials you want to authenticate as

.Parameter AzTenantId
    Defaults to (Get-AzureRmTenant)[0].id

.Parameter AzClientId
    Defaults to the well known PowerShell client id
#>
function Get-AzureToken {
    [cmdletBinding(DefaultParameterSetName="ims")]
    param([Parameter()]
            [ValidateSet("AzureDevOps","DataLake","EventHubs","KeyVault","ResourceManager","ServiceBus","Sql","Storage")]
            [string]$ResourceName = "ResourceManager"
        , [Parameter(ParameterSetName="ims")][string]$ApiVersion = "2018-02-01"
        , [Parameter(ParameterSetName="ims")][switch]$AsToken
        , [Parameter(ParameterSetName="az")][pscredential]$AzCredential
        , [Parameter(ParameterSetName="az")][string]$AzTenantId
        , [Parameter(ParameterSetName="az")][string]$AzClientId = '1950a258-227b-4e31-a9cf-717495945fc2' # Set well-known client ID for Azure PowerShell
        , [Parameter()][String]$ResourceOverride
    )
    
    $resourceIds = @{
        ResourceManager = "https://management.azure.com/"
        KeyVault = "https://vault.azure.net/"
        DataLake = "https://datalake.azure.net/"
        Sql = "https://database.windows.net/"
        EventHubs = "https://eventhubs.azure.net/"
        ServiceBus = "https://servicebus.azure.net/"
        Storage = "https://storage.azure.com/"
        AzureDevOps = "499b84ac-1321-427f-aa17-267ca6975798"
    }
    
    if(-not $ResourceOverride) { $ResourceOverride = $resourceIds[$ResourceName] }
    if($AzCredential) {
        if(-not $AzTenantId) {
            if(Get-Module -ListAvailable Az.Accounts) { $AzTenantId = (Get-AzTenant)[0].id } 
            else { throw "Please load the Az.Accounts module and connect to Azure first or provide a TenantId via -AzTenantId!" }
        }

        $authority = 'https://login.microsoftonline.com/common/' + $AzTenantId
        Write-Verbose "Authority: $authority"
       
        $AADcredential = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential]::new($AzCredential.UserName, $AzCredential.Password)
        $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
        #$authResult = $authContext.AcquireTokenAsync($ResourceOverride,$AzClientId,$AADcredential) # old AzureRm way
        $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $ResourceOverride, $AzClientId, $AADcredential).Result;
        "bearer " + $authResult.AccessToken
    }
    else {
        [string]$Uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version={0}&resource={1}" -f $ApiVersion, $ResourceOverride

        if($AsToken) {
            "Bearer {0}" -f (Invoke-RestMethod -Uri $Uri -ContentType "application/json" -Method Get -Headers @{Metadata=$true} |
                Select-Object -ExpandProperty access_token)
        }
        else { Invoke-RestMethod -Uri $Uri -ContentType "application/json" -Method Get -Headers @{Metadata=$true} }
    }
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