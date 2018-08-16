Set-StrictMode -Version Latest
#$ErrorActionPreference = "Stop"

[string]$dataPath = "$home\AppData\Low\SimplyCredential"
$script:AppListPath = Join-Path $dataPath "AppList.clixml"
$script:CredListPath= Join-Path $dataPath "CredList.clixml"

if(-not (Test-Path -Path $dataPath)) { New-Item -Path $dataPath -ItemType Directory -Force | Out-Null }

if(Test-Path $Script:AppListPath) { $script:AppList = Import-Clixml $script:AppListPath }
else { $script:AppList = @{} }

if(Test-Path $Script:CredListPath) { $script:CredList = Import-Clixml $script:CredListPath }
else { $script:CredList = @{} }

$CreateProcessWithLogonW = @"
    [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
       public static extern bool CreateProcessWithLogonW(
          String             userName,
          String             domain,
          String             password,
          int         logonFlags,
          String             applicationName,
          String             commandLine,
          int         creationFlags,
          int             environment,
          String             currentDirectory,
          ref StartupInfo       startupInfo,
          out ProcessInformation     processInformation);

    [StructLayout(LayoutKind.Sequential)]
    public struct ProcessInformation 
    {
        public IntPtr hProcess;
        public IntPtr hThread;
        public int dwProcessId;
        public int dwThreadId;
    }
    
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct StartupInfo
    {
        public Int32 cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public Int32 dwX;
        public Int32 dwY;
        public Int32 dwXSize;
        public Int32 dwYSize;
        public Int32 dwXCountChars;
        public Int32 dwYCountChars;
        public Int32 dwFillAttribute;
        public Int32 dwFlags;
        public Int16 wShowWindow;
        public Int16 cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }
"@

Add-Type -MemberDefinition $CreateProcessWithLogonW -Namespace SimplyCredential -Name PInvoke

#Load up base Classes

#Dot source functions
ForEach($f in Get-ChildItem $PSScriptRoot -filter "*.ps1" -File) {
    Try { . $f.fullname }
    Catch { Write-Error "Failed to import function $($f.fullname): $_" }
}


# Register ArgumentCompleter
Register-ArgumentCompleter -CommandName "Use-Credential", "Save-Credential", "Remove-Credential", "Show-Credential" -ParameterName Name -ScriptBlock {
    Param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $script:CredList.Keys | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', ("UserName: {0}" -f $script:CredList[$_].UserName))
        }
}

Register-ArgumentCompleter -CommandName "Use-Application", "Save-Application", "Remove-Application", "Show-Application" -ParameterName Name -ScriptBlock {
    Param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $script:AppList.Keys | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $script:AppList[$_].Path) }
}

# Clean variables
Remove-Variable f, CreateProcessWithLogonW, dataPath