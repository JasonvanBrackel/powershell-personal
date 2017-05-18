$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"

Describe "Package-ApprendaAddOn" {
    # Mock the temp drive
    $rootDrive = $TestDrive
    $tempDrive = "$rootDrive\$([System.Guid]::NewGuid().ToString())"
    Mock Join-Path { return $tempDrive }

    #Mock the GAC
    $GACPath = "$rootDrive\GAC"
    New-Item -ItemType Directory -Path $GACPath
    Mock Get-ChildItem -ParameterFilter { $Path -eq "$env:windir\assembly\GAC*" -and $Include -eq "SaaSGrid.API.dll"  } -MockWith { return "$GACPath\SaaSGrid.API.dll" }
    New-FakeFile "$GACPath\SaaSGrid.API.dll"

    #Mock the inputs
    $ArchivePath = "$rootDrive\archive.zip"

    $AddOnPath = "$rootDrive\Fake.AddOn.dll"
    New-FakeFile $AddOnPath 

    $AddOnDirectory = "$rootDrive\FakeAddOn"
    New-FakeFolder $AddOnDirectory

    $ManifestPath = "$rootDrive\AddonManifest.xml"
    New-FakeFile $ManifestPath

    $IconPath = "$rootDrive\FakeIcon.gif"
    New-FakeFile $IconPath

    $APIPath = "$rootDrive\SaaSGrid.API.dll"
    New-FakeFile $APIPath
    
    # Mock the write hosts to verify they're called
    Mock Write-Host -ParameterFilter { $Object -eq "Packaging $AddOnPath" }
    Mock Write-Host -ParameterFilter { $Object -eq "Packaging $ManifestPath"}
    Mock Write-Host -ParameterFilter { $Object -eq "Packaging $IconPath"}
    Mock Write-Host -ParameterFilter { $Object -eq "Packaging $APIPath"}

    Context "SaaSGrid.API is GAC'd and an APIPath is not provided." {
        Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnPath -ManifestPath $ManifestPath -IconPath $IconPath
        $destinationPath = "$rootDrive\Destination"
        Expand-Archive -Path $ArchivePath -DestinationPath $destinationPath
        It "should package the SaaSGrid.API.dll file from the GAC" {
            Assert-FilesAreTheSame -OriginalFolder $GACPath -DestinationFolder $destinationPath -FileName "SaaSGrid.API.dll"
        }
        Remove-Item "$rootDrive\Destination" -Recurse -Force
    }

    Context "SaaSGrid.API is not GAC'd and an APIPath is not provided." {
        Mock Get-ChildItem -ParameterFilter { $Path -eq "$env:windir\assembly\GAC*" -and $Include -eq "SaaSGrid.API.dll"  } -MockWith { return "" }
        It "should throw and message the user that the SaaSGrid.API.dll file is not in the GAC" {
            { Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnPath -ManifestPath $ManifestPath -IconPath $IconPath } | 
                Should throw "Apprenda SaaSGrid.API.dll was not found in the Global Assembly Cache."
        }
    }

    Context "APIPath is not found." {
        It "should throw and messsage that the SaaSGrid.API.dll was not found." {
            { Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnPath -ManifestPath $ManifestPath -IconPath $IconPath -APIPath ".\NotHere\SaaSGrid.API.dll" } | 
                Should throw "Apprenda SaaSGrid.API.dll was not found at .\NotHere\SaaSGrid.API.dll."
            
        }
    }

    Context "Add-On path is a directory" {
        Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnDirectory -ManifestPath $ManifestPath -IconPath $IconPath -APIPath $APIPath     
        $destinationPath = "$rootDrive\Destination"
        Expand-Archive -Path $ArchivePath -DestinationPath $destinationPath   
        It "should copy all the files from the directory." { 
            Assert-OriginalFilesAreIncludedInDestination -OriginalFolder "$rootDrive\FakeAddOn" -DestinationFolder $destinationPath
        }
        Remove-Item "$rootDrive\Destination" -Recurse -Force
    }

    Context "Add-On is a single file" {
        Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnPath -ManifestPath $ManifestPath -IconPath $IconPath -APIPath $APIPath       
        $destinationPath = "$rootDrive\Destination"
        Expand-Archive -Path $ArchivePath -DestinationPath $destinationPath 
        It "should copy the single file." {
            Assert-FilesAreTheSame -OriginalFolder $rootDrive -DestinationFolder $destinationPath -FileName "Fake.AddOn.dll"
        }
        Remove-Item "$rootDrive\Destination" -Recurse -Force
    }

    Package-ApprendaAddOn -ArchivePath $ArchivePath -AddOnPath $AddOnPath -ManifestPath $ManifestPath -IconPath $IconPath -APIPath $APIPath    
    $destinationPath = "$rootDrive\Destination"
    Expand-Archive -Path $ArchivePath -DestinationPath $destinationPath
    It "should copy the SaaSGrid.Apprenda.dll." {
        Assert-FilesAreTheSame -OriginalFolder $rootDrive -DestinationFolder $destinationPath -FileName "SaaSGrid.API.dll"        
    }

    It "should copy the icon File" {
        Assert-FilesAreTheSame -OriginalFolder $rootDrive -DestinationFolder $destinationPath -FileName "FakeIcon.gif"        
    }

    It "should message that the addon is being copied." {
        Assert-MockCalled Write-Host -ParameterFilter { $Object -eq "Packaging $AddOnPath" }
    }

    It "should message that the manifest is being copied." {
        Assert-MockCalled Write-Host -ParameterFilter { $Object -eq "Packaging $ManifestPath" }
    }

    It "should message that the icon is being copied." {
        Assert-MockCalled Write-Host -ParameterFilter { $Object -eq "Packaging $IconPath" }
    }

    It "should message that the SaaSGrid.API.dll is being copied." {
        Assert-MockCalled Write-Host -ParameterFilter { $Object -eq "Packaging $APIPath" }
    }

    It "should create the archive file." {
        Test-Path $ArchivePath | Should Be $true
    }

    It "should clean up after itself." {
        Test-Path $tempDrive | Should Be $false
    }
}
