Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Build-PowershellModule {
    [CmdletBinding()]
    param
    (
        [string]$ModuleName
    )
    process {
        Write-Host "Clean build directory: $ModuleName"

        $buildPath = ".\$ModuleName"
        if(Test-Path $buildPath)
        {
            Remove-Item -Path $buildPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $buildPath
                
        "Gathering Scripts"
        $file = Get-Item -Path *.ps1 -Exclude *.Tests.ps1  | Get-Content | where { !($_.StartsWith('$ErrorActionPreference', "CurrentCultureIgnoreCase")) -and !($_.StartsWith("Set-StrictMode", "CurrentCultureIgnoreCase")) -and !($_.StartsWith(". .\", "CurrentCultureIgnoreCase")) }

        "Writing $ModuleName.psm1"
        $psmPath = "$buildPath\$ModuleName.psm1"
        $startOfFile = @('Set-StrictMode -Version Latest', '$ErrorActionPreference = ''Stop''')
        $startOfFile | Out-File $psmPath
        $file | Get-Content | Out-File $psmPath -Append

        "Copying Contents"
        $psdPath = "$buildPath\$ModuleName.psd1"
        Copy-Item ".\$ModuleName.psd1" $psdPath

        try {
            "Testing Import"
            Import-Module $buildPath -Verbose
        } finally {
            "Removing Module"
            Remove-Module $ModuleName
        }

        if($Error.Count > 0) {
            throw $Error[0]
        }

        Remove-Item .\0
    }
}