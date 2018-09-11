<#
.Synopsis
    Creates a PSSession with Azure specific configuration.

.Description
    Creates a PSSession with Azure specific configuration.
        UseSSL = True
        SessionOption.SkipCACheck = True
        SessionOption.SkipCNCheck = True

.Parameter ComputerName
    ComputerName to create a session against.

.Parameter Credential
    Credentials to use for the PSSession.

#>
function New-AzurePSSession {
    param([parameter(Mandatory)][Alias("Server","DnsName")][string]$ComputerName
        , [parameter(Mandatory)][Alias("VmCred")][pscredential]$Credential
    )

    $splat = @{
        ComputerName = $ComputerName
        Credential = $Credential
        UseSSL = $true
        SessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
        Name = $ComputerName.split(".")[0]
    }

    New-PSSession @splat
}

Export-ModuleMember -Function New-AzurePSSession