Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. .\Test-MsBuildInstalled.ps1

 <#
    .SYNOPSIS
        Publishes a visual studio solution using a given publish profile.

    .DESCRIPTION
        Publishes a visual studio solution using a given publish profile. When the profile is not there, the project will be built but that published.  This is due the behavior of msbuild

    .PARAMETER SolutionPath
        Path to the Visual Studio solutions file.

    .PARAMETER ProfileName
        Profile in the solution to be used.

    .PARAMETER Configuration
        Build configuration to be published.  Defaults to "Debug".

    .EXAMPLE
        This publishes a solution file using a profile "ProfileName" and the build Configuration "Release"
        Publish-Solution .\SolutionFile.sln ProfileName Release


    #>
function Publish-Solution {
    [CmdletBinding()]
    param
    (
        [string]$SolutionPath,
        [string]$ProfileName,
        [string]$Configuration="Debug"
    )
    process 
    {
        if(!(Test-Path($SolutionPath)))
        {
            throw "No file was found at $SolutionPath."
        }

        if(!(Test-MsBuildInstalled)) {
            throw "MSBuild not found! Publish-Solution depends on MSBuild.  Please install MSBuild."
        }

        Invoke-Expression "MSBuild $SolutionPath /p:DeployOnBuild=true /p:PublishProfile=$ProfileName"
    }

}