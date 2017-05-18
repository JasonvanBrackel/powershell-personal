Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Encode-ToBase64.ps1"

function New-ApprendaAddOn {
    [CmdletBinding()]
    param(
        [string]$Alias = "",
        [string]$Path
    )
    process {
        if (!(Test-Path variable:global:apprendasession)) {
            throw "No current Apprenda Session found.  Aborting."
        } 

        $contents = Encode-ToBase64 -Path $Path

        $url = "$($apprendaSession.url)/soc/api/v1/addons"
        $body =  @{ alias = $Alias; contents = $contents } 
        $body = $body | ConvertTo-Json
                       
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
