<#
.Synopsis
    Removes a saved application reference.

.Description
    Removes a saved application reference and persists this
    information to disk at $home\AppData\Low\SimplyCredential\.

.Parameter Name
    The reference name of the application.
#>
function Remove-Application {
    param([Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][string]$Name)

    if($script:AppList.Keys -contains $name) { 
        $script:AppList.Remove($name)
        $script:AppList | Export-Clixml -Path $script:AppListPath -Force
    }
    else { Write-Warning "The application reference '$name' does not exist." }
}

Export-ModuleMember -Function Remove-Application