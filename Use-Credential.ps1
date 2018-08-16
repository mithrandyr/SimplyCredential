<#
.Synopsis
    Uses a saved credential.

.Description
    Uses a saved credential.

.Parameter Name
    The name of the credential.
#>
function Use-Credential {
    [cmdletBinding()]
    param([Parameter(ValueFromPipeline)][string]$Name = "Default")

    if($script:CredList.keys -contains $Name) { $script:CredList[$Name] }
    else { Write-Error "The credential '$name' does not exist." }
}

Export-ModuleMember -Function Use-Credential