Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-ApprendaAddOnInstance {
    [CmdletBinding()]
    param(
        [string]$Alias,
        [string]$InstanceAlias,
        [string]$DeveloperOptions = ""
    )
    
    process {
        if (!(Test-Path variable:global:apprendasession)) {
            throw "No current Apprenda Session found.  Aborting."
        } 

        $url = "$($apprendaSession.url)/developer/api/v1/addons/$Alias"
        $body = @{ InstanceAlias = $InstanceAlias; DeveloperOptions = $DeveloperOptions   } | ConvertTo-Json

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
