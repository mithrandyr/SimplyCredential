<#
.Synopsis
    Saves a PSCredential object to the specified name.

.Description
    Saves a [PSCredential] object to the specified name and persists
    this information to the disk at $home\AppData\Low\SimplyCredential\.

.Parameter Name
    The reference name for the [PSCredential].

.Parameter Credential
    The [PSCredential] to persist.

.Parameter Force
    Use this to overwrite an existing saved credential.
#>
function Save-Credential {
    param([Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$Name
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)][pscredential]$Credential
        , [switch]$Force)
    
    if($script:CredList.Keys -notcontains $name -or $Force) { 
        $script:CredList[$Name] = $Credential
        $script:CredList | Export-Clixml -Path $script:CredListPath -Force
    }
    else { throw "The credential '$name' already exists, use -Force to overwrite." }
}

Export-ModuleMember -Function Save-Credential