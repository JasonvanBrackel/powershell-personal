Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. .\Build-PowershellModule.ps1

function Package-PowershellModule {
    [CmdletBinding()]
    param
    (
        [string]$ModuleName
    )
    process {
        $buildPath = ".\$ModuleName"

        if(!(Test-Path $buildPath))
        {
            "$ModuleName Apprenda-Powershell Module not available.  Building now."
            Build-PowershellModule $ModuleName
        }

        "Creating the Powershell Archive"
        Compress-Archive -Path $buildPath -DestinationPath ".\$ModuleName.zip" -CompressionLevel Optimal -Force
    }
}

