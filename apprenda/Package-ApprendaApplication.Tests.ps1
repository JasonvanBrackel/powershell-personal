$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"
Describe "Package-ApprendaApplication" {

    # Create paths for single test files
    $manifestPath = "$testDrive\manifest.xml"
    $warPath = "$testDrive\JavaWebApplication.war"
    $applicationProvisioningScriptPath = "$testDrive\applicationProvisioningScript.sql"
    $tenantProvisionScriptPath = "$testDrive\tenantProvisioningScript.sql"
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
    $services = New-FakeObjectCollection "services" $testDrive
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

    Package-ApprendaApplication -ArchivePath $archivePath `
                                -ManifestPath $manifestPath `
                                -Wars $warPath `
                                -ApplicationProvisioningScript $applicationProvisioningScriptPath `
                                -TenantProvisioningScript $tenantProvisionScriptPath `
                                -PatchScripts $patchScripts `
                                -Services $services `
                                -Interfaces $interfaces `
                                -WindowsServices $winServices `
                                -LinuxServices $linuxServices `
                                -Libraries $libraries


    $archiveFolder = "$testDrive\archive"
    Expand-Archive -Path $archivePath -DestinationPath $archiveFolder

    It "should package the manifest in the root of the archive" {
        $manifestFile = Get-Item -Path "$archiveFolder\manifest.xml"
        (Get-Content $manifestFile) | Should Be (Get-Content $manifestPath)
    }

    It "should package each service in the services folder." {
        foreach($service in $services) {
            $fileName = [System.IO.Path]::GetFileName($service.Path)
            $originalFolder = Get-ChildItem -Path $service.Path -Recurse
            $serviceFolder = Get-ChildItem -Path "$archiveFolder\services\$($service.Name)" -Recurse
            $comparision = Compare-Object -ReferenceObject $serviceFolder -DifferenceObject $originalFolder -IncludeEqual
            $comparision.SideIndicator | Should Be "=="
        }
    }

    It "should package each interface in the interfaces folder." {
        foreach($interface in $interfaces) {
            $fileName = [System.IO.Path]::GetFileName($interface.Path)
            $originalFolder = Get-ChildItem -Path $interface.Path -Recurse
            $interfaceFolder = Get-ChildItem -Path "$archiveFolder\interfaces\$($interface.Name)" -Recurse
            $comparision = Compare-Object -ReferenceObject $interfaceFolder -DifferenceObject $originalFolder -IncludeEqual
            $comparision.SideIndicator | Should Be "=="
        }
    }

    It "should package each library into the lib folder under services." {
        foreach($library in $libraries) {
            $fileName = [System.IO.Path]::GetFileName($library)
            $libraryFile = Get-Item -Path "$archiveFolder\services\lib\$fileName"
            (Get-Content $libraryFile) | Should Be (Get-Content $library)
        }
    }

    It "should package the war in the wars folder" {
        $warFile = Get-Item -Path "$archiveFolder\wars\JavaWebApplication.war"
        (Get-Content $warFile) | Should Be (Get-Content $warPath)
        
    }

    It "should package the windows services in the winservices folder" {
        foreach($item in $winServices) {
            $fileName = [System.IO.Path]::GetFileName($item.Path)
            $originalFolder = Get-ChildItem -Path $item.Path -Recurse
            $destinationFolder = Get-ChildItem -Path "$archiveFolder\winservices\$($item.Name)" -Recurse
            $comparision = Compare-Object -ReferenceObject $destinationFolder -DifferenceObject $originalFolder -IncludeEqual
            $comparision.SideIndicator | Should Be "=="
        }
    }

    It "should package the linuxServices in the linuxservices folder" {
        foreach($item in $linuxServices) {
            $fileName = [System.IO.Path]::GetFileName($item.Path)
            $originalFolder = Get-ChildItem -Path $item.Path -Recurse
            $destinationFolder = Get-ChildItem -Path "$archiveFolder\linuxServices\$($item.Name)" -Recurse
            $comparision = Compare-Object -ReferenceObject $destinationFolder -DifferenceObject $originalFolder -IncludeEqual
            $comparision.SideIndicator | Should Be "=="
        }
    }

    It "should package the application provisioning script in the scripts folder in the persistence folder" {
        $script = Get-Item -Path "$archiveFolder\persistence\scripts\applicationprovisioningscript.sql"
        (Get-Content $script) | Should Be (Get-Content $applicationProvisioningScriptPath)
    }

    It "should package the tenant provisioning script in the scripts folder in the persistence folder" {
        $script = Get-Item -Path "$archiveFolder\persistence\scripts\tenantprovisioningscript.sql"
        (Get-Content $script) | Should Be (Get-Content $tenantProvisionScriptPath)
    }

    It "should package the patch scripts in the persistence folder in a subfolder named for the type of patch script"{
        foreach($script in $patchScripts) {
            $fileName = [System.IO.Path]::GetFileName($script.Path)
            $scriptFile = Get-Item -Path "$archiveFolder\persistence\scripts\$($script.Type)\$fileName" 
            (Get-Content $scriptFile) | Should Be (Get-Content $script.Path)
        }
    }

    It "should package the application at the provided path" {
        Test-Path($archivePath) | Should Be $true
    }
}


