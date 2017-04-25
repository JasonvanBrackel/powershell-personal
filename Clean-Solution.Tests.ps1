$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Clean-Solution" {
    $configuration = "Debug"
    $solutionPath = Join-Path $testDrive "CleanSolutiontest.sln"
    Copy-Item ./CleanSolutionTest -Recurse $solutionPath
    Mock Invoke-Expression -Verifiable -ParameterFilter { "MSBuild $solutionPath /t:clean /p:configuration=$configuration"}
    
    Context "No file exists at the path given" {
        $solutionPath = Join-Path $testDrive "Doesnotexist.sln"
        It "throws an exception with a message that no file was found" {
            { Clean-Solution $solutionPath $configuration  } | Should Throw "No file was found at $solutionPath."
        }
    }
    
    Context "MSBuild is not installed" {    
        Mock Test-MsBuildInstalled { return $false }

        It "throws an exception that it can't find ms-build." {
            { Clean-Solution $solutionPath $configuration } | Should Throw "MSBuild not found! Clean-Solution depends on MSBuild.  Please install MSBuild."
        }
    }

    It "Runs MSBuild clean function against the given solution" {
        Clean-Solution $solutionPath $configuration
        Assert-VerifiableMocks        
    }
}
