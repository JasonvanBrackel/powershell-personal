Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Package-ApprendaAddOn {
    <#
    .SYNOPSIS
        Packages an apprenda addon archive from an existing sources.
    .DESCRIPTION
        This Cmdlet is designed to allow to user to describe build an apprenda add on per http://docs.apprenda.com/current/addoncreation
    
    .PARAMETER ArchivePath
        Path to write the archive zip file as described in (http://docs.apprenda.com/current/addoncreation).
        
    .PARAMETER AddOnPath
        Path to the AddOn dll or to the directory containing the Add-On binaries.

    .PARAMETER ManifestPath
        Path to the AddOnManifest.xml file as described in (http://docs.apprenda.com/current/addoncreation#manifest).
    
    .PARAMETER IconPath
        Path to the Icon that will be used when the Add-On is referenced in the Apprenda Developer Portal and the Apprenda SOC.
        By convention the platform looks for an icon named icon.png.

    .PARAMETER APIPath
        Path to the SaaSGrid.API.dll library required to be packaged with each Apprenda Add-On.  If this path is not 
        provided, the GAC will be searched and that copy will be used to build the archive.  If the path is not 
        provided and the dll is not in the GAC the Cmdlet will throw and error.


    .EXAMPLE
        This example provides all the components necessary to build an Apprenda Add-On archive from a pre-built Visual Studio Solution directory.
        $configuration = 'Debug'
        Package-ApprendaAddOn -ArchivePath $addOnPath -AddOnPath "./src/AddOn/bin/$configuration" -ManifestPath "./src/Manifests/AddonManifest.xml" -IconPath "./src/Icons/logstash.gif" -APIPath "./lib/Apprenda 6.7.0/SaaSGrid.API.dll"

    .EXAMPLE
        This example provides all the components necessary to build an Apprenda Add-On archive from a pre-built Visual Studio Solution directory, but relies on the SaaSGrid.API.dll to be available in the GAC.
        $configuration = 'Debug'
        Package-ApprendaAddOn -ArchivePath $addOnPath -AddOnPath "./src/AddOn/bin/$configuration" -ManifestPath "./src/Manifests/AddonManifest.xml" -IconPath "./src/Icons/logstash.gif"

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchivePath,
        [Parameter(Mandatory = $true)]
        [string]$AddOnPath,
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath,
        [Parameter(Mandatory = $true)]
        [string]$IconPath,
        [Parameter(Mandatory = $false)]
        [string]$APIPath
           
    )
    process {
        $tempDirectory = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
        New-Item $tempDirectory -ItemType Directory -Force
        
        if (!(Test-Path($AddOnPath))) {
            throw "Apprenda Add-On dll or Add-On folders not found at $AddOnPath."   
        }
        else {
            Write-Host "Packaging $AddOnPath"
            if ((Get-Item $AddOnPath) -is [System.IO.DirectoryInfo]) {
                Get-ChildItem $AddOnPath -Recurse | % { Copy-Item -Path $_.FullName -Destination $tempDirectory }
            }
            else {
                Copy-Item -Path (Get-ChildItem $AddOnPath -Recurse) -Destination $tempDirectory
            }
        }

        if (!(Test-Path($ManifestPath))) {
            throw "Apprenda Add-On manifest file not found at $ManifestPath"
        }
        else {
            Write-Host "Packaging $ManifestPath"
            Copy-Item -Path (Get-ChildItem $ManifestPath -Recurse) -Destination $tempDirectory
        }

        if (![string]::IsNullOrWhiteSpace($APIPath)) {
            if (!(Test-Path($APIPath))) {
                throw "Apprenda SaaSGrid.API.dll was not found at $APIPath."
            }
            else {
                Write-Host "Packaging $APIPath"
                Copy-Item -Path (Get-ChildItem $APIPath -Recurse) -Destination $tempDirectory
            }
        }
        else {
            "No APIPath provided checking the GAC for SaaSGrid.API.dll"
            $APIPath = Get-ChildItem -Path "$env:windir\assembly\GAC*" -Include "SaaSGrid.API.dll" | Select-Object -First 1
            if ([string]::IsNullOrWhiteSpace($APIPath)) {
                throw "Apprenda SaaSGrid.API.dll was not found in the Global Assembly Cache."
            }

            if (!(Test-Path($APIPath))) {
                throw "Apprenda SaaSGrid.API.dll was not found in the Global Assembly Cache."
            }
            else {
                Write-Host "Packaging $APIPath"
                Copy-Item -Path (Get-ChildItem $APIPath -Recurse) -Destination $tempDirectory
            }
        }

        if (![string]::IsNullOrWhiteSpace($IconPath)) {
            if (!(Test-Path($IconPath))) {
                throw "Add-On Icon was not found at $IconPath."
            }
            else {
                Write-Host "Packaging $IconPath"
                Copy-Item -Path (Get-ChildItem $IconPath -Recurse) -Destination $tempDirectory
            }
        } 

        "Creating the Archive"
        Compress-Archive -Path  $tempDirectory\* -DestinationPath $ArchivePath -CompressionLevel Optimal -Force

        "Cleaning up Temp Directory"
        Remove-Item $tempDirectory -Recurse -Force
    }

}
