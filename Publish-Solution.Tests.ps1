$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Publish-Solution" {
    $configuration = "Debug"
    $solutionPath = Join-Path $testDrive "CleanSolutiontest.sln"
    $profileName = "TestProfileName"
    Copy-Item ./CleanSolutionTest -Recurse $solutionPath

    Mock Test-MsBuildInstalled { return $true }
    Mock Invoke-Expression -Verifiable -ParameterFilter { "MSBuild $solutionPath /p:DeployOnBuild=true /p:PublishProfile=$profileName"}
    
    Context "No file exists at the path given" {
        $solutionPath = Join-Path $testDrive "Doesnotexist.sln"
        It "throws an exception with a message that no file was found" {
            { Publish-Solution $solutionPath $profileName $configuration  } | Should Throw "No file was found at $solutionPath."
        }
    }
    
    Context "MSBuild is not installed" {  
        Mock Test-Path { return $true }
        Mock Test-MsBuildInstalled { return $false }

        It "throws an exception that it can't find MSBuild." {
            { Publish-Solution $solutionPath $profileName $configuration } | Should Throw "MSBuild not found! Publish-Solution depends on MSBuild.  Please install MSBuild."
        }
    }

    It "Runs MSBuild build function against the given solution" {
        Publish-Solution $solutionPath $profileName $configuration
        Assert-VerifiableMocks        
    }
}
