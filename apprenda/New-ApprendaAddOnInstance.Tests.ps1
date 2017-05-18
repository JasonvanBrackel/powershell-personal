Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"


Describe "New-ApprendaAddOnInstance" {
    $expectedAlias = "addOnAlias"
    $expectedInstanceAlias = "addOnInstance"

    Context "User is not logged in." {
        Mock Test-Path { return $false }
        
        It "should throw an error that the user was not logged in." {
            { New-ApprendaAddOnInstance -Alias $expectedAlias -InstanceAlias $expectedInstanceAlias  } | Should throw "No current Apprenda Session found.  Aborting."
        }
    }

    $expectedDeveloperOptions = "options"
    $expectedBody = @{ InstanceAlias = $expectedInstanceAlias; DeveloperOptions = $expectedDeveloperOptions }  | ConvertTo-Json
    $mockSession = New-MockApprendaSession
    $expectedUrl = "$($mockSession.url)/developer/api/v1/addons/$expectedAlias"
    Mock Invoke-RestMethod -Verifiable -ParameterFilter { 
        $Method -eq 'Post' -and 
        $Uri -eq $expectedUrl -and 
        $Headers -eq $mockSession.headers -and 
        $Body -eq $expectedBody
    }

    New-ApprendaAddOnInstance -Alias $expectedAlias -InstanceAlias $expectedInstanceAlias -DeveloperOptions $expectedDeveloperOptions
    
    It "should call the POST Method of the AddOns endpoint of the Application Management API" {
        Assert-VerifiableMocks
    }
}
