$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Build-Solution" {
    $configuration = "Debug"
    $solutionPath = Join-Path $testDrive "CleanSolutiontest.sln"
    Copy-Item ./CleanSolutionTest -Recurse $solutionPath

    Mock Test-MsBuildInstalled { return $true }
    Mock Invoke-Expression -Verifiable -ParameterFilter { "$solutionPath /m /maxcpucount /p:Configuration=$configuration"}
    
    Context "No file exists at the path given" {
        $solutionPath = Join-Path $testDrive "Doesnotexist.sln"
        It "throws an exception with a message that no file was found" {
            { Build-Solution $solutionPath $configuration  } | Should Throw "No file was found at $solutionPath."
        }
    }
    
    Context "MSBuild is not installed" {  
        Mock Test-Path { return $true }
        Mock Test-MsBuildInstalled { return $false }

        It "throws an exception that it can't find MSBuild." {
            { Build-Solution $solutionPath $configuration } | Should Throw "MSBuild not found! Build-Solution depends on MSBuild.  Please install MSBuild."
        }
    }

    It "Runs MSBuild build function against the given solution" {
        Build-Solution $solutionPath $configuration
        Assert-VerifiableMocks        
    }
}
