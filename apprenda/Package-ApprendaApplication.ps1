Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

<#
    .SYNOPSIS
        Packages an apprenda archive from an existing source folder

    .DESCRIPTION
        This Cmdlet is designed to allow to user to describe the layout of binaries to be deployed in an Apprenda Archive from a folder with apprenda application binaries.

    .PARAMETER ManifestPath
        Path to the DeploymentManifest.xml file as described in (http://docs.apprenda.com/current/deployment-manifest).

    .PARAMETER Interfaces
        A list of interfaces to be packaged into the archive's interfaces folder.
        These are IIS hosted user interfaces (http://docs.apprenda.com/current/asp-net-sites).
        Each will be described as an object with properties Name and Path, 
        where Name is the name of the resulting folder in the archive's
        interfaces folder and Path is the path to the binaries ready to be package.
        
    .PARAMETER Services
        A list of web services to be packaged into the archive's services folder.
        These are .NET WCF Services (http://docs.apprenda.com/current/wcf-web-services).
        Each will be described as an object with properties Name and Path, 
        where Name is the name of the resulting folder in the archive's
        services folder and Path is the path to the binaries ready to be package.

    .PARAMETER WindowsServices
        A list of windows services to be packaged into the archive's services folder.
        These are Windows Services (http://docs.apprenda.com/current/winservices_dev).
        Each will be described as an object with properties Name and Path, 
        where Name is the name of the resulting folder in the archive's
        services folder and Path is the path to the binaries ready to be package.

    .PARAMETER LinuxServices
        A list of linux services to be packaged into the archive's services folder.
        These are Windows Services (http://docs.apprenda.com/current/linuxservices).
        Each will be described as an object with properties Name and Path, 
        where Name is the name of the resulting folder in the archive's
        services folder and Path is the path to the binaries ready to be package.

    .PARAMETER Wars
        A Java War file to be packaged into the archive's war folder and is described in 
        (http://docs.apprenda.com/current/wars).  Currently (as of 6.8) only one War is 
        supported, but multiple war support is expected in a future version of Apprenda.

    .PARAMETER Libraries
        A list of paths to binaries to be copied to the lib folder under services described in (http://docs.apprenda.com/current/creating-app-archives).

    .PARAMETER ApplicationProvisioningScript
        Path to the application provisioning script as described in (http://docs.apprenda.com/current/working-with-data)

    .PARAMETER TenantProvisioningScript
        Path to the tenant provisioning script as described in (http://docs.apprenda.com/current/working-with-data)

    .PARAMETER PatchScripts
        Path to patch scripts for upgrading databases from version to version as described in (http://docs.apprenda.com/current/creating-app-archives#patching)

    .PARAMETER ArchivePath
        Path to write the archive zip file as described in (http://docs.apprenda.com/current/creating-app-archives).

    .EXAMPLE
        The example below includes a Deployment Manifest, Two interfaces and an application provisioning script.

        Package-Application \
        -manifestPath .\source\Manifests\UiDeploymentManifest.xml \
        -interfaces @{ Name="root"; Path=".\source\Ui\bin" }, @{ Name="api"; Path=".\source\webapi\bin" } \
        -applicationProvisioningScript '.\Database Scripts\DB_Provision.sql' \
        -archivePath $archivePath

    #>
function Package-ApprendaApplication {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $ManifestPath,
        [Parameter()]
        [System.Object[]]$Interfaces,
        [Parameter()]
        [System.Object[]]$Services,
        [Parameter()]
        [System.Object[]]$Libraries,        
        [Parameter()]
        [System.Object[]]$Wars,     
        [Parameter()]
        [System.Object[]]$WindowsServices,  
        [Parameter()]
        [System.Object[]]$LinuxServices, 
        [Parameter()]
        [string] $ApplicationProvisioningScript,
        [Parameter()]
        [string] $TenantProvisioningScript,
        [Parameter()]
        [System.Object[]]$PatchScripts,
        [Parameter(Mandatory=$true)]
        [string] $ArchivePath
    )

    ######################## Support Functions ########################
    function Copy-ObjectCollection
    (
        [string]$collectionName,
        [System.Object[]]$collection,
        [string]$collectionFolder,
        [string]$tempDir
    )
    {
        foreach($item in $collection) {
            "Copy $collectionName $($item.Name)"
            $collectionPath = Join-Path -Path $tempDir -ChildPath $collectionFolder
            if(!(Test-Path $collectionPath)){
                New-Item -ItemType Directory -Path $collectionPath
            }
            $destinationPath = Join-Path -Path $collectionPath -ChildPath $item.Name
            Get-ChildItem -Path $item.Path | Copy-Item -Destination $destinationPath -Recurse -Force
        }
    }

    function Copy-PathCollection 
    (
        [string]$collectionName,
        [System.Object[]]$paths,
        [string]$collectionFolder,
        [string]$tempDir
    )
    {
        foreach($path in $paths) {
            "Copying $collectionName"
            $destinationPath = Join-Path -Path $tempPath -ChildPath $collectionFolder
            if(!(Test-Path $destinationPath)){
                New-Item -ItemType Directory -Path $destinationPath
            }
            Get-ChildItem -Path $path | Copy-Item -Destination $destinationPath -Recurse -Force
        }
    }

    function Copy-ProvisioningScript
    (
        [string]$scriptType,
        [string]$scriptPath
    ) 
    {
        if(![string]::IsNullOrWhiteSpace($scriptPath) -and (Test-Path $scriptPath))
        {
            "Copying $scriptType"
            $persistencePath = Join-Path $tempDir -ChildPath Persistence
            if(!(Test-Path $persistencePath)) {
                New-Item -ItemType Directory $persistencePath
            }
            Copy-Item -Path $scriptPath -Destination $persistencePath
        }

    }

    function Copy-PatchScripts
    (
        [System.Object[]]$scripts
    )
    {
        foreach($patchScript in $scripts) {
            "Copying $($patchScript.Type) patch script $($patchScript.Path)"

            $persistencePath = Join-Path $tempDir -ChildPath Persistence
            if(!(Test-Path $persistencePath)) {
                New-Item -ItemType Directory $persistencePath
            }

            if($patchScript.Type.ToLower() -eq "data") {
                $scriptPath = Join-Path $persistencePath -ChildPath data
                if(!(Test-Path $scriptPath))
                {
                    New-Item -ItemType Directory $scriptPath
                }
                Copy-Item -Path $patchScript.Path -Debug $scriptPath
            }

            if($patchScript.Type.ToLower() -eq "schema") {
                $scriptPath = Join-Path $persistencePath -ChildPath schema
                if(!(Test-Path $scriptPath))
                {
                    New-Item -ItemType Directory $scriptPath
                }
                Copy-Item -Path $patchScript.Path -Debug $scriptPath
            }
        }
    }

    ######################## End Support Functions ########################

    "Copying the Application Manifest."
    Copy-Item $ManifestPath -Destination $tempDir

    "Copying the Interfaces."
    Copy-ObjectCollection "Interface" $Interfaces "interfaces" $tempDir
    "Interfaces copied."

    "Copying the Services."
    Copy-ObjectCollection "WCF Service" $Services "services" $tempDir 
    "Services copied."
    
    "Copying Libraries."
    Copy-PathCollection "Library" $Libraries "lib" $tempDir
    "Libraries copied."

    "Copying Java Web Application Archives"
    Copy-PathCollection "War" $Wars "wars" $tempDir
    "Java Web Application Archives copied."

    "Copying Windows Services"
    Copy-ObjectCollection "Windows Service" $WindowsServices "winservices" $tempDir
    "Windows Services copied."

    "Copying Linux Services"
    Copy-ObjectCollection "Linux Service" $LinuxServices "linuxServices" $tempDir
    "Linux Services copied."

    "Copying the Application Provisoning Script"
    Copy-ProvisioningScript "Application Provisioning Script" $ApplicationProvisioningScript
    "Application Provisioning Script copied."

    "Copying the Tenant Provisioning Script"
    Copy-ProvisioningScript "Tenant Provisioning Script" $TenantProvisioningScript
    "Tenant Provisioning Script copied."

    "Copying Patch Scripts"
    Copy-PatchScripts $PatchScripts
    "Patch Scripts copied."
   
    "Creating the archive"
    Compress-Archive -Path  $tempDir\* -DestinationPath .\$archivePath -CompressionLevel Optimal -Force

    "Cleaning up $tempDir"
    Remove-Item $tempDir -Recurse -Force
}
    