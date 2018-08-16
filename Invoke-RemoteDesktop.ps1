<#
.Synopsis
    Invokes the RDP client (MSTSC)

.Parameter ComputerName
    The computer to connect to (supports both "server" and "server:port" syntax)

.Parameter Port
    The port on the computer to connect to (parameter is ignored if port is specified in "server")

.Parameter Admin
    Switch to invoke admin mode (i.e. console session)

.Parameter Credential
    Specify the credentials to use in order to auto login and bypass the login dialog.

.Parameter FullScreen
    Switch to invoke fullscreen mode

.Parameter Height
    Specifies the height of the rdp desktop.

.Parameter Width
    Specifies the width of the rdp desktop.

.Parameter Resolution
    Specifies the width and height of the rdp desktop.
    Can be overridden by -Height and/or -Width.

#>
function Invoke-RemoteDesktop {
    [cmdletBinding()]
    Param( [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][alias("Server")][string]$ComputerName
        , [Parameter()][int]$Port
        , [Parameter()][switch]$Admin
        , [Parameter()][pscredential]$Credential
        , [Parameter(Mandatory, ParameterSetName="FullScreen")][switch]$FullScreen
        , [Parameter(ParameterSetName="ScreenSize")][int]$Height
        , [Parameter(ParameterSetName="ScreenSize")][int]$Width
        , [Parameter(ParameterSetName="ScreenSize")][ValidateSet("800x600","1024x768","1280x1024")][string]$Resolution)


    [string[]]$argArray = $null

    if($ComputerName -like "*:*") { $argArray += "/v:{0}:{1}" -f ($ComputerName -split ":")[1], ($ComputerName -split ":")[0] }
    elseif($port -gt 0) { $argArray += "/v:{0}:{1}" -f $ComputerName, $port }
    else { $argArray += "/v:$ComputerName" }
    
    if($Admin) { $argArray += "/admin"}
    
    if($FullScreen) { $argArray += "/f" }
    else {
        $w, $h = 0, 0
        if($Resolution) { $w, $h = $Resolution -split "x" }
        if($Width) { $w = $Width }
        if($Height) { $h = $Height }

        if($w -gt 0) { $argArray += "/w:$w" }
        if($h -gt 0) { $argArray += "/h:$h" }
    }
    
    Write-Verbose ($argarray -join " ")
    
    if($Credential) {
        Start-Process -FilePath "cmdkey.exe" -ArgumentList ("/generic:TERMSRV/{0} /user:{1} /pass:{2}" -f $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password) -WindowStyle Hidden -Wait
        Start-Sleep -Milliseconds 100
        Start-Process -FilePath "mstsc.exe" -ArgumentList $argArray
        Start-Sleep -Seconds 5
        Start-Process -FilePath "cmdkey.exe" -ArgumentList "/delete:TERMSRV/$ComputerName" -WindowStyle Hidden -Wait
    }
    else { Start-Process -FilePath "mstsc.exe" -ArgumentList $argArray }
}

New-Alias -Name rdp -value Invoke-RemoteDesktop
Export-ModuleMember -Function Invoke-RemoteDesktop -Alias rdp