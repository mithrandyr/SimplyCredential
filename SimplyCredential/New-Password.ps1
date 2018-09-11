<#
#>
function New-Password {
    Param([Parameter()][int]$Length = 8
        , [Parameter()][switch]$NoSpecialCharacters
        , [Parameter()][switch]$NoNumbers
        , [Parameter()][switch]$NoUpperCase
        , [Parameter()][string]$IncludeCharacters
        , [Parameter()][string]$ExcludeCharacters
        , [Parameter()][switch]$DisplayPossibleCharacters)
    
    $PossibleCharacters = "abcdefghijklmnopqrstuvwxyz"
    if(-not $NoUpperCase) { $PossibleCharacters += "abcdefghijklmnopqrstuvwxyz".ToUpper() }
    if(-not $NoNumbers) { $PossibleCharacters += "0123456789" }
    if(-not $NoSpecialCharacters){ $PossibleCharacters += "!@#$%^&*()+=\/?<>.-_{}[]:;" }
    if($IncludeCharacters)
    {
        for ($i = 0; $i -lt $IncludeCharacters.length; $i ++)
        {
            $m = [regex]::Escape($IncludeCharacters[$i].tostring())
            if($PossibleCharacters -cnotmatch $m) {$PossibleCharacters += $IncludeCharacters[$i].tostring()}
        }
    }
    
    if($ExcludeCharacters)
    {
        for ($i = 0; $i -lt $ExcludeCharacters.length; $i ++)
        {
            $m = [regex]::Escape($ExcludeCharacters[$i].tostring())
            if($PossibleCharacters -cmatch $m) {$PossibleCharacters = $PossibleCharacters -replace $m}
        }
    }
    
    [string]$password = ""
    [int]$mL = $PossibleCharacters.length
    
    for($i = 0 ; $i -lt $length; $i ++) { $password += $possibleCharacters[(Get-Random -Minimum 0 -Maximum $ml)].ToString() }
    
    Write-Output $password
    if($DisplayPossibleCharacters) {Write-Host "Possible Characters: $PossibleCharacters"}
}
Export-ModuleMember -Function New-Password