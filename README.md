# Powershell
This is my collection of personal powershell scripts.

# Building and installing the Powershell Scripts
1. Dot source the build scripts.  Do this from the tools directory because of the dot source dependencies in the file
```powershell
Set-Location tools
. .\Build-PowershellModule.ps1
. .\Package-PowershellModule.ps1
. .\Deploy-PowershellModule.ps1
```

2. From the directory where the powershell scripts live.  The psd1 file will need to have the same name as the moduleName variable. The example file is PowershellJvB.psd1 which is what I use on my own machines.
```powershell
$moduleName = "WhateverYouWantToNameIt"
Build-PowershellModule $moduleName
Package-PowershellModule $moduleName
Deploy-PowershellModule $moduleName
```
