Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Set-ApprendaGlobalLogLevel {
[CmdletBinding()]
    param(
        [string]$LogLevel
    )
    process {
        if(!(Test-Path variable:global:apprendasession)) {
            throw "No current Apprenda Session found.  Aborting."
        } 

        switch($LogLevel) {
            "debug" {
                $newLevel = 1
            } 
            "info" {
                $newLevel = 2
            }
            "warn" {
                $newLevel = 3
            }
            "error" {
                $newLevel = 4
            }
            "fatal" {
                $newLevel = 5
            }
            default {
                throw "Log level $LogLevel is not recognized.  Acceptable log levels are debug, info, warn, error, fatal."
            }
        }

        $url = "$($apprendaSession.url)/soc/LogAdministration.asmx/SetLogLevel"
        $body = "{ newLevel: `"$newLevel`" }"

                       
        # See http://social.technet.microsoft.com/wiki/contents/articles/29863.powershell-rest-api-invoke-restmethod-gotcha.aspx
        $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($url)
        $response = Invoke-RestMethod `
		  -Method Post `
		  -Uri $url `
		  -Headers $apprendaSession.headers `
          -Body $body
        $ServicePoint.CloseConnectionGroup("")

        return $response

    }
}
