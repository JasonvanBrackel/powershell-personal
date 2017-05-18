# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

# Describe "Set-ApprendaPlatformEndUserStorePlugin" {
#     Context "User is not logged in." {
#         Mock Test-Path { return $false }

#         It "should throw an error that the user was not logged in." {
#             { Set-ApprendaPlatformEndUserStorePlugin "path doesn't matter."  } | Should throw "No current Apprenda Session found.  Aborting."
#         }   
#     }

#     #Create a mock apprenda session
#     $fakeSession = @{
#         url = "https://apps.fake"
#         username = "fakeUser"
#         password = ("fakePassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
#         tenantAlias = "fakeTenant"
#         sessionToken = "fakeSessionToken"
#         headers = @{
#             "Content-Type"="application/json" 
#             "ApprendaSessionToken"="fakeSessionToken"
#             "charset"="UTF-8" 
#         }
#     }

#     Context "File doesn't exist at the path provided" {
#         $fakePath = "$testDrive\doesnotexist.zip"

#         { Set-ApprendaPlatformEndUserStorePlugin $fakePath } | Should throw "End user store plugin was not found at $fakePath.  Aborting."
#     }


#     Set-Variable -Scope Global -Name apprendaSession -Value $fakeSession
    
#     $expectedUrl = "$($apprendaSession.url)/soc/LogAdministration.asmx/SetLogLevel"
    
#     Mock Test-Path { return $true }

#     It "should upload the plugin." {
        
#     }
    
    
    


    
    

# }
