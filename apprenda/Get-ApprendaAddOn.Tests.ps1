$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\test-helpers.ps1"

Describe "Get-ApprendaAddOn" {
    Context "User is not logged in." {
        Remove-Variable -Name apprendaSession -Scope Global -ErrorAction SilentlyContinue
        It "should throw an error that the user was not logged in." {
            { Get-ApprendaAddOn "doesn't matter" } | Should throw "No current Apprenda Session found.  Aborting."
        }
    }

    #Mock the Sesson
    $session = New-MockApprendaSession
    $expectedAlias = "expectedAlias"

    #Mock the request
    $expectedUri = "$($session.url)/soc/api/v1/addons/$expectedAlias"

    Mock Invoke-RestMethod -ParameterFilter { $Method -eq 'Get' -and $Uri -eq $expectedUri -and $Headers -eq $session.headers } -Verifiable

    Get-ApprendaAddOn -Alias $expectedAlias

    It "calls the AddOn Get method in the Platform Operator API to get the add-on" {
        Assert-VerifiableMocks
    }
}
