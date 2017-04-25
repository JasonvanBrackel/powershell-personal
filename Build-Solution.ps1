Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. .\Test-MsBuildInstalled.ps1

<#
    .SYNOPSIS
        Builds a visual studio solution using a given solution file.

    .DESCRIPTION
        Builds a visual studio solution using a given solution file.

    .PARAMETER SolutionPath
        Path to the Visual Studio solutions file.

    .PARAMETER Configuration
        Build configuration to be built.  Defaults to "Debug".

    .EXAMPLE
        This builds a solution using the "Release" configuration
        Build-Solution .\SolutionFile.sln Release

    #>
function Build-Solution {
[CmdletBinding()]
param
(
    [string]$solutionPath,
    [string]$configuration="Debug"
) 
process
    {
        if(!(Test-Path($solutionPath)))
        {
            throw "No file was found at $solutionPath."
        }

        if(!(Test-MsBuildInstalled)) {
            throw "MSBuild not found! Build-Solution depends on MSBuild.  Please install MSBuild."
        }

        Invoke-Expression "MSBuild $solutionPath /m /maxcpucount /p:Configuration=$configuration"
    }
}