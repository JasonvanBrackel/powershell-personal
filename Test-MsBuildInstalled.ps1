Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. .\Get-MsBuildVersion

function Test-MsBuildInstalled {
    $versions = Get-MsBuildVersion

    return !(($versions -eq $null) -or ($versions | Measure-Object | Select-Object -Property Count) -eq 0)
}
