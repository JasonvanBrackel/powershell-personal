$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Test-MsBuildInstalled" {
    Context "MSBuild is installed." {
        $fakeKey = New-MockObject -Type Microsoft.Win32.RegistryKey
        Mock Get-MsBuildVersion { return @($fakeKey) }
        $result = Test-MsBuildInstalled

        It "Should return true." {
            $result | Should Be $true
        }
    }

    Context "MSbuild is not installed." {
        Mock Get-MsbuildVersion { return $null }
        $result = Test-MsBuildInstalled

        It "Should return false." {
            $result | Should Be $false
        }
    }

    Mock Get-MsBuildVersion -Verifiable

    It "Call Get-MsbuildVersion" {
        Assert-MockCalled "Get-MsBuildVersion"
    }
}
