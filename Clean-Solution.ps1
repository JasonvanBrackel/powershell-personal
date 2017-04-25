Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. .\Test-MsBuildInstalled.ps1

<#
    .SYNOPSIS
        Cleans a visual studio solution using a given solution file.

    .DESCRIPTION
        Cleans a visual studio solution using a given solution file.

    .PARAMETER SolutionPath
        Path to the Visual Studio solutions file.

    .PARAMETER Configuration
        Configuration to be cleaned.  Defaults to "Debug".

    .EXAMPLE
        This builds a solution using the "Release" configuration
        Build-Solution .\SolutionFile.sln Release

    #>
function Clean-Solution { 
    [CmdletBinding()]
    param
    (
        [string]$solutionPath,
        [string]$configuration = "Debug"
    )
    process
    {
        # Make sure there's a file
        if(!(Test-Path($solutionPath)))
        {
            throw "No file was found at $solutionPath."
        }

        # Check for MS Build
        if(!(Test-MsBuildInstalled)) {
            throw "MSBuild not found! Clean-Solution depends on MSBuild.  Please install MSBuild."
        }

        Invoke-Expression "MSBuild $solutionPath /t:clean /p:configuration=$configuration" 
    }
}