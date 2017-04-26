Push-Location .\tools

. .\Build-PowershellModule.ps1
. .\Deploy-PowershellModule.ps1
. .\Package-PowershellModule.ps1

Pop-Location

$moduleName = "PowershellJvB"

Build-PowershellModule $moduleName
Package-PowershellModule $moduleName
Deploy-PowershellModule $moduleName