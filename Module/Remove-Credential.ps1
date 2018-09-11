<#
.Synopsis
    Removes a PSCredential object associated with the specified name.

.Description
    Removes a PSCredential object associated with the specified name and
    persists this information to the disk at $home\AppData\Low\SimplyCredential\.

.Parameter Name
    The reference name for the [PSCredential].
#>
function Remove-Credential {
    param([Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)][string]$Name)
    
    if($script:CredList.Keys -contains $name) { 
        $script:CredList.Remove($name)
        $script:CredList | Export-Clixml -Path $script:CredListPath -Force
    }
    else { Write-Warning "The credential '$name' does not exist." }
}

Export-ModuleMember -Function Remove-Credential