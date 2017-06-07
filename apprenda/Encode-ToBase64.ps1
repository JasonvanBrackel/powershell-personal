Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Encode-ToBase64 {
    <# 
    .SYNOPSIS
        Returns a Base64 string representation of a file
    
    .DESCRIPTION
        Gets the byte content of a file and converts those bytes to a base 64 string.
    
    .PARAMETER Path
        Path to the file to be encoded.
    
    .EXAMPLE
        Encode-ToBase64 -Path "C:\Temp\AFile.zip"
#>
    [CmdletBinding()]
    param(
        [string]$Path
    ) process {
        $bytes = Get-Content $Path -Encoding Byte
        $string = [System.Convert]::ToBase64String($bytes)
        return $string
    }
}
