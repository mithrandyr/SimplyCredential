<#
.Synopsis
    List all saved application references.

.Description
    List all saved credentials.

.Parameter Name
    The name of the application reference, accepts wildcards.
#>
function Show-Application {
    param([Parameter(ValueFromPipeline)][string]$Name
        , [switch]$IncludeObject)

    if($script:AppList.Count -gt 0) {
        $script:AppList.keys |
            Where-Object { $_ -like $Name } |
            ForEach-Object {
                    $app = $script:AppList[$Name]
                    $obj = [PSCustomObject]@{
                            Name = $_
                            Type = if($app.NetworkOnly) { "Network Only" }
                                    elseif($app.AsAdmin -and $app.WithUserProfile) { "Elevated User with Profile" }
                                    elseif($app.AsAdmin) { "Elevated User" }
                                    elseif($app.WithUserProfile) { "User with Profile" }
                                    else { "User" }
                            Path = $app.Path
                            Arguments = $app.Arguments
                        }
                    if($IncludeObject) { $app | Add-Member -NotePropertyName Object -NotePropertyValue $app }
                    $obj
                } |
            Sort-Object -Property Name
    }
}

Export-ModuleMember -Function Show-Application