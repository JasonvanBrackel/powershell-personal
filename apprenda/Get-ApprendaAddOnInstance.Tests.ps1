Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"


Describe "Get-ApprendaAddOnInstance" {
    $expectedAlias = "addOnAlias"
    $expectedInstanceAlias = "addOnInstance"

    Context "User is not logged in." {
        Mock Test-Path { return $false }
        
        It "should throw an error that the user was not logged in." {
            { Get-ApprendaAddOnInstance -Alias $expectedAlias -InstanceAlias $expectedInstanceAlias  } | Should throw "No current Apprenda Session found.  Aborting."
        }
    }

    $mockSession = New-MockApprendaSession
    $expectedUrl = "$($mockSession.url)/developer/api/v1/addons/$expectedAlias/$expectedInstanceAlias"
    Mock Invoke-RestMethod -Verifiable -ParameterFilter { 
        $Method -eq 'Get' -and 
        $Uri -eq $expectedUrl -and 
        $Headers -eq $mockSession.headers
    }

    Get-ApprendaAddOnInstance -Alias $expectedAlias -InstanceAlias $expectedInstanceAlias
    
    It "should call the GET Method of the AddOns endpoint of the Application Management API" {
        Assert-VerifiableMocks
    }
}
