$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-MsBuildVersion" {
    Mock Get-ChildItem -MockWith { return @( [pscustomobject]@{Name = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions\1.0"; Property="Test"}, [pscustomobject]@{ Name="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions\2.0"; Property = "Test 2" } ) }  -Verifiable -ParameterFilter { $Path -eq "HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions\" }

    $result = Get-MsBuildVersion

    It "Should call the registry to get the installed copies of MSBuild." {
        Assert-VerifiableMocks
    }

    It "Should sort the return copies newest first" {
        ($result | Select-Object -First 1).Name | Should BeLike "*2.0"
        ($result | Select-Object -Last 1).Name | Should BeLike "*1.0"
    }

    Context "When requesting a specific version" {
        $result = Get-MsBuildVersion "1.0"
        It "Should only return that version." {
            ($result | Select-Object -First 1).Name | Should BeLike "*1.0"
        }
    }

    Context "When requestiong the latest version" {
        $result = Get-MsBuildVersion "Latest"
        It "Should only return the latest version." {
            ($result | Select-Object -First 1).Name | Should BeLike "*2.0"
        }
    }
}
