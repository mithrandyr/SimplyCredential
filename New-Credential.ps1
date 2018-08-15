<#
.Synopsis
    Creates a new PSCredential object.

.Description
    Creates a new [PSCredential] object.

.Parameter UserName
    UserName for the [PSCredential].

.Parameter Password
    Password for the [PSCredential, in plain text.

.Parameter SecurePassword
    Password for the [PSCredential], as a [securestring].
#>
function New-Credential {
    param([Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$UserName
    , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="unsecure")][string]$Password
    , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="secure")][securestring]$SecurePassword)

    if($SecurePassword) { return [pscredential]::new($UserName, $SecurePassword) }
    else { return [pscredential]::new($UserName, (ConvertTo-SecureString -String $Password -AsPlainText -Force)) }
}

Export-ModuleMember -Function New-Credential