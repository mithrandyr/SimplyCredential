<#
.Synopsis
    List all saved credentials.

.Description
    List all saved credentials and display their passwords if -ShowPassword
    is used.    

.Parameter Name
    The names to display, accepts wildcards.
#>
function Show-Credential {
    param([Parameter(ValueFromPipeline)][string[]]$Name = "*"
        , [switch]$ShowPassword)

    $script:CredList |
        Where-Object {
                $t = $_
                $t.Name -in $Name -or
                ($Name | Where-Object {$t.Name -like $_}).Count -gt 0
            } |
        Sort-Object Name
}

Export-ModuleMember -Function Show-Credential