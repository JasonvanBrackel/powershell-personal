$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Package-ApprendaApplication" {
    # Create paths for single test files
    $manifestPath = "$testDrive\manifest.xml"
    $warPath = "$testDrive\JavaWebApplication.war"
    $applicationProvisioningScriptPath = "$testDrive\applicationProvisionScript.sql"
    $tenantProvisionScriptPath = "$testDrive\tenantProvisionScript.sql"
    $patchScript1Path = "$testDrive\patchScriptData1.sql"
    $patchScript2Path = "$testDrive\patchScriptData2.sql"
    $patchScript3Path = "$testDrive\patchScriptSchema1.sql"
    $patchScript4Path = "$testDrive\patchScriptSchema2.sql"
    $archivePath = "$testDrive\archive.zip"

    # Create fake files and objects
    New-Fakefile $manifestPath
    New-Fakefile $warPath
    New-Fakefile $patchScript1Path
    New-Fakefile $patchScript2Path
    New-Fakefile $patchScript3Path
    New-Fakefile $patchScript4Path
    New-Fakefile $tenantProvisionScriptPath
    New-Fakefile $applicationProvisioningScriptPath
    $services = New-FakeObjectCollection "service" $testDrive
    $interfaces = New-FakeObjectCollection "interface" $testDrive
    $winServices = New-FakeObjectCollection "winservice" $testDrive
    $linuxServices = New-FakeObjectCollection "linuxService" $testDrive
    $libraries = New-FakeFileCollection $testDrive
    $patchScripts = @( 
                        [pscustomobject]@{Type = "data"; Path = $patchScript1Path}, 
                        [pscustomobject]@{Type = "data"; Path = $patchScript2Path}, 
                        [pscustomobject]@{Type = "schema"; Path = $patchScript3Path}, 
                        [pscustomobject]@{Type = "schema"; Path = $patchScript4Path} 
                    )

    $result = Package-ApprendaApplication \
                -ManifestPath $manifestPath \
                -Interfaces $interfaces \
                -Services $services \
                -Libraries $libraries \
                -Wars $warPath \
                -WindowsServices $winServices \
                -LinuxServices $linuxServices \
                -ApplicationProvisioningScript $applicationProvisioningScriptPath \
                -TenantProvisioningScript $tenantProvisionScriptPath \
                -PatchScripts $patchScripts

    It "should package each service in the services folder." {
        foreach($service in $services) {
        
        }
    }

    It "should package each interface in the interfaces folder." {
        foreach($interface in $interfaces) {

        }
    }

    It "should package each library into the lib folder under services." {
        foreach($library in $libraries) {

        }
    }

    It "should package the war in the wars folder" {
        
    }

    It "should package the windows services in the winservices folder" {
        foreach($winService in $winServices) {

        }
    }

    It "should package the linuxServices in the linuxservices folder" {
        foreach($linuxService in $linuxServices) {

        }
    }

    It "should package the application provisioning script in the scripts folder in the persistence folder" {
        
    }

    It "should package the tenant provisioning script in the scripts folder in the persistence folder" {
        
    }

    It "should package the data patch scripts in the persistence folder in a subfolder named data"{

    }

    It "should package the schema patch scripts in the persistence folder in a subfolder named schema" {
        
    }

    It "should package the application at the provided path" {
        
    }

}

function New-FakeObjectCollection
(
    [string]$name,
    [string]$path
) 
{
    $count = Get-Random -Minimum 1 -Maximum 5
    $list = [System.Collections.ArrayList]::new()
    for($index = 1; $index -le $count; $index++) {
        $folderPath = Join-Path $path ([System.IO.Path]::GetRandomFileName())
        New-FakeFolder ($folderPath)
        $list.Add([pscustomobject]@{ Name = "$name$count"; Path = $folderPath})
    }

    return $list.ToArray()
}

function New-FakeFileCollection
(
    [string]$path
)
{
    $count = Get-Random -Minimum 1 -Maximum 5
    $list = [System.Collections.ArrayList]::new()
    for($index = 1; $index -le $count; $index++) {
        $filePath = (Join-Path $path ([System.IO.Path]::GetRandomFileName()))
        New-Fakefile $filePath
        $list.Add($filePath)
    }

    return $list.ToArray()
}

function New-Fakefile
(
    [string]$path
) 
{
    New-Item -ItemType "text" -Path $path  
    Set-Content -Path $path -Value (-join ((65..90) + (97..122) | Get-Random -Count (Get-Random -Maximum 40000) | % {[char]$_}))
}

function New-FakeFolder
(
    [string]$path
)
{
    New-Item
    $fakeFolderCount = Get-Random -Minimum 1 -Maximum 10
    $fakeFileCount = Get-Random -Minimum 1 -Maximum 20


    (1..$fakeFileCount) | New-Fakefile -path (Join-Path $path ([System.IO.Path]::GetRandomFileName()))
    (1..$fakeFolderCount) | New-FakeFolder -path (Join-Path $path ([System.IO.Path]::GetRandomFileName()))
}
