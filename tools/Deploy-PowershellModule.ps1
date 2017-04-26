Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. .\Build-PowershellModule.ps1

function Deploy-PowershellModule {
    param
    (
        [string]$ModuleName
    )
    process {
        $modulePath = ".\$ModuleName"
        if(!(Test-Path $modulePath))
        {
            "$ModuleName Module not available.  Building now."
            Build-PowershellModule $ModuleName
        }

        "Removing the module if it exists."
        Remove-Module $ModuleName -ErrorAction SilentlyContinue

        "Finding the user's Powershell profile path"
        $deployPath = $env:PSModulePath.Split(';') | ? {$_ -like '*Users*' } | Select -First 1

        if($deployPath -eq $null -or !(Test-Path variable:deploypath)) {
            "User deployment path not found."
            $deployPath = $env:PSModulePath.Split(';') | ? {$_ -like '*Program*' } | Select -First 1

            "Going to attempt to deploy to $deployPath."
        }

        "Removing the current module if it exists at $deployPath"
        if(Test-Path $deployPath) {
            Remove-Item -Recurse -Force (Join-Path $deployPath "$ModuleName") -ErrorAction SilentlyContinue
        }

        "Deploying the module"
        Copy-Item -Path $modulePath  -Destination (Join-Path $deployPath "$ModuleName") -Recurse

        "Importing the module"
        Import-Module $ModuleName

    }
}


