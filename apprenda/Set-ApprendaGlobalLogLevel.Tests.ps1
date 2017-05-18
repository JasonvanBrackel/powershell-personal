$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"

Describe "Set-ApprendaGlobalLogLevel" {
    Context "User is not logged in." {
        Mock Test-Path { return $false }

        It "should throw an error that the user was not logged in." {
            { Set-ApprendaGlobalLogLevel  } | Should throw "No current Apprenda Session found.  Aborting."
        }
    }

    Mock Test-Path { return $true }
    #Create a mock apprenda session
    New-MockApprendaSession
    
    $fakeUrl = "$($apprendaSession.url)/soc/LogAdministration.asmx/SetLogLevel"

    Context "User sends and invalid log level." {
        
        $logLevel = "Bad"
        It "should throw an error that " {
            { Set-ApprendaGlobalLogLevel $logLevel } | Should throw "Log level $loglevel is not recognized.  Acceptable log levels are debug, info, warn, error, fatal."
        }
    }

    
    Context "User sets log level to Debug." {
        $logLevel = "debug"
        $expectedBody = "{ newLevel: `"1`" }"
        Mock Invoke-RestMethod -ParameterFilter { $Uri -eq $fakeUrl; $Method -eq "Post" ; $Headers -eq $fakeSession.headers; $Body -eq $expectedBody  } -Verifiable

        Set-ApprendaGlobalLogLevel $loglevel

        It "should send 1 to the /LogAdministration.asmx/SetLogLevel endpoint." {
            Assert-VerifiableMocks
        }
    }

    Context "User sets log level to Info." {
        $logLevel = "info"
        $expectedBody = "{ newLevel: `"1`" }"
        Mock Invoke-RestMethod -ParameterFilter { $Uri -eq $fakeUrl; $Method -eq "Post" ; $Headers -eq $fakeSession.headers; $Body -eq $expectedBody  } -Verifiable

        Set-ApprendaGlobalLogLevel $loglevel

        It "should send 2 to the /LogAdministration.asmx/SetLogLevel endpoint." {
            Assert-VerifiableMocks
        }
    }

    Context "User sets log level to Warn." {
        $logLevel = "warn"
        $expectedBody = "{ newLevel: `"1`" }"
        Mock Invoke-RestMethod -ParameterFilter { $Uri -eq $fakeUrl; $Method -eq "Post" ; $Headers -eq $fakeSession.headers; $Body -eq $expectedBody  } -Verifiable

        Set-ApprendaGlobalLogLevel $loglevel

        It "should send 3 to the /LogAdministration.asmx/SetLogLevel endpoint." {
            Assert-VerifiableMocks
        }
    }

    Context "User sets log leve to Error." {
        $logLevel = "error"
        $expectedBody = "{ newLevel: `"1`" }"
        Mock Invoke-RestMethod -ParameterFilter { $Uri -eq $fakeUrl; $Method -eq "Post" ; $Headers -eq $fakeSession.headers; $Body -eq $expectedBody  } -Verifiable

        Set-ApprendaGlobalLogLevel $loglevel

        It "should send 4 to the /LogAdministration.asmx/SetLogLevel endpoint." {
            Assert-VerifiableMocks
        }
    }

    Context "User sets log level to Fatal." {
        $logLevel = "fatal"
        $expectedBody = "{ newLevel: `"1`" }"
        Mock Invoke-RestMethod -ParameterFilter { $Uri -eq $fakeUrl; $Method -eq "Post" ; $Headers -eq $fakeSession.headers; $Body -eq $expectedBody  } -Verifiable

        Set-ApprendaGlobalLogLevel $loglevel

        It "should send 5 to the /LogAdministration.asmx/SetLogLevel endpoint." {
            Assert-VerifiableMocks            
        }
    }
}
