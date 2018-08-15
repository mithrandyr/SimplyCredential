<#
.Synopsis
    List all saved credentials.

.Description
    List all saved credentials and display their passwords if -ShowPassword
    is used.    

.Parameter Name
    The name to display, accepts wildcards.
#>
function Show-Credential {
    param([Parameter(ValueFromPipeline)][string]$Name = "*"
        , [switch]$ShowPassword)

    if($script:CredList.Count -gt 0) {
        $script:CredList.keys |
            Where-Object { $_ -like $Name } |
            ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        UserName = $script:CredList[$_].UserName
                        Password = if($ShowPassword) { $script:CredList[$_].GetNetworkCredential().Password } else { "********" }
                    }
                } |
            Sort-Object -Property Name
    }        
}

Export-ModuleMember -Function Show-Credential