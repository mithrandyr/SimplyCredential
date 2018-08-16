<#
.Synopsis
    Uses a saved credential.

.Description
    Uses a saved credential.

.Parameter Name
    The name of the credential.

.Parameter Arguments
    Overrides the arguments saved with the application reference.

.Parameter AsAdmin
    Runs the application reference in an elevated context.

.Parameter WithUserProfile
    Runs the application reference with a loaded user profile.

.Parameter UseCurrentDirectory
    Runs the application reference with the current directory as
    the working directory.
#>
function Use-Application {
    param([Parameter(Mandatory, ValueFromPipeline)][string]$Name
        , [Parameter(Mandatory)][pscredential]$Credential
        , [Parameter()][string]$Arguments
        , [Parameter()][switch]$AsAdmin
        , [Parameter()][switch]$WithUserProfile
        , [Parameter()][switch]$UseCurrentDirectory)

    if($script:AppList.keys -contains $Name) {
        $app = $script:AppList[$Name]
        if($app.NetworkOnly -and ($AsAdmin -or $WithUserProfile)) { throw "Cannot use -AsAdmin or -WithUserProfile with a saved 'Network Only' application." }
        
        #Working Directory Override
        [string]$exePath = $app.path
        [string]$exeFolder = Get-Location | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        if(Test-Path $app.Path) {
            [string]$exePath = Resolve-Path -Path $app.Path | Select-Object -ExpandProperty ProviderPath
            if(-not $UseCurrentDirectory) { [string]$exeFolder = Split-Path $exePath -Parent }
        }

        #Arguments Override
        if($Arguments) { $app.Arguments = $Arguments }

        #Credential UserName parsing
        $userName = $Credential.UserName
        $userDomain = ""
        if($Credential.UserName -like "*@*") { $userDomain = $null }
        if($Credential.UserName -like "*\*") { $userName, $userDomain = $Credential.UserName.Split("\") }
                        
        if($app.NetworkOnly) {  
            if(-not [SimplyCredential.PInvoke]::CreateProcessWithLogonW($userName, $userDomain, $Credential.GetNetworkCredential().Password, 2, $exePath, $app.Arguments, 0, 0, $exeFolder, [ref]@{}, [ref]@{})) {
                throw ("Could not properly launch '{0}' with the arguments '{1}' for the account '{2}' (networkOnly)." -f $app.Path, $app.arguments, $Credential.UserName)
            }
        }
        else {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.Arguments = $app.Arguments
            $psi.FileName = $exePath
            $psi.WorkingDirectory = $exeFolder
            $psi.CreateNoWindow = $false
            $psi.UseShellExecute = $false            
            $psi.UserName = $userName
            $psi.Domain = $userDomain
            $psi.Password = $Credential.Password
            
            if($app.WithUserProfile -or $WithUserProfile) { $psi.LoadUserProfile = $true }
            if($app.AsAdmin -or $AsAdmin)
            {
                $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
                $psi.FileName = "powershell"
                $psi.Arguments = ("-noprofile -encodedCommand {0}" -f [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$exePath $Arguments")))
            }

            [System.Diagnostics.Process]::Start($psi) | Out-Null   
        }
    }
    else { Write-Error "The application reference '$name' does not exist." }
}

Export-ModuleMember -Function Use-Application