<#
.Synopsis
    Saves the startup parameters for an application.

.Description
    Saves the startup parameters for an application and persists
    this information to disk at $home\AppData\Low\SimplyCredential\.

.Parameter Name
    The reference name of the application.

.Parameter Path
    Path to the executable.

.Parameter Arguments
    Arguments to be used with the executable,
    can be overridden in 'Use-Application'.

.Parameter NetworkOnly
    Runs the application as the current user, except for
    operations that take place over the network.

.Parameter AsAdmin
    Runs the application in an elevated context.

.Parameter WithUserProfile
    Runs the application with a loaded user profile.

.Parameter Force
    Use this to overwrite an existing saved application.

#>
function Save-Application {
    param([Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$Name
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$Path
        , [Parameter(ValueFromPipelineByPropertyName)][string]$Arguments
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="netonly")][switch]$NetworkOnly
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="user")][switch]$AsAdmin
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="user")][switch]$WithUserProfile
        , [switch]$Force
    )

    if(-not (Test-Path -Path $Path -PathType Leaf) -and -not (Get-Command -Name $path -ErrorAction Ignore)) { throw "'$path' is not a valid file!" }
    if($script:AppList.Keys -notcontains $name -or $Force) { 
        $script:AppList[$Name] = [PSCustomObject]@{
            Path = $Path
            Arguments = $Arguments
            NetworkOnly = $NetworkOnly.IsPresent
            AsAdmin = $AsAdmin.IsPresent
            WithUserProfile = $WithUserProfile.IsPresent
        }
        
        $script:AppList | Export-Clixml -Path $script:AppListPath -Force
    }
    else { throw "The credential '$name' already exists, use -Force to overwrite." }
    
}

Export-ModuleMember -Function Save-Application