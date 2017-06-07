Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"
. "$here\Encode-ToBase64.ps1"

Describe "New-ApprendaAddOn" {
    #Mock the Archive
    $expectedPath = "$testDrive\archive.zip"
    New-FakeFile $expectedPath
    $expectedEncodedString = "encodedfile"  
    Mock Encode-ToBase64 -MockWith { return $expectedEncodedString } -ParameterFilter { $Path -eq $expectedPath }

    Context "User is not logged in." {
        Remove-Variable -Name apprendaSession -Scope Global -ErrorAction SilentlyContinue
        It "should throw an error that the user was not logged in." {
            { New-ApprendaAddOn -Alias "don'tmatter" -Path "alsodoesntmatter"  } | Should throw "No current Apprenda Session found.  Aborting."
        }
    }

    #Mock the Sesson
    $session = New-MockApprendaSession
    $expectedAlias = "expected"

    #Mock the request
    $expectedBody =  @{ alias = $expectedAlias; contents = $expectedEncodedString } | ConvertTo-Json
    $expectedUri = "$($session.url)/soc/api/v1/addons"

    Mock Invoke-RestMethod -ParameterFilter { $Method -eq 'Post' -and $Uri -eq $expectedUri -and $Headers -eq $session.headers -and $Body -eq $expectedBody  }

    New-ApprendaAddOn -Alias $expectedAlias -Path $expectedPath
    
    It "should encode the archive" {
        Assert-MockCalled Encode-ToBase64 -ParameterFilter { $Path -eq $expectedPath }
    }

    It "calls the AddOn POST method in the Platform Operator API to crate the add-on" {
        Assert-MockCalled Invoke-RestMethod -ParameterFilter { $Method -eq 'Post' -and $Uri -eq $expectedUri -and $Headers -eq $session.headers -and $Body -eq $expectedBody  }
    }
}
