Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ApprendaAddOn {
    <#
    .SYNOPSIS
        Gets an Apprenda-AddOn based by alias in the Apprenda SOC
    .DESCRIPTION
        Returns the http response an is a facade for the Platform Management API calls for add ons.
        http://docs.apprenda.com/swagger/platformops/v1/endpoints.html#/Add-Ons.
        If a 404 is returned the Cmdlet will throw.
    .PARAMETER Alias
        The alias of the AddOn in the Apprenda SOC
    .EXAMPLE
        Get-ApprendaAddOn -Alias "logstash"
        Gets an apprenda AddOn named logstash
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias
    )
    process {   
        if (!(Test-Path variable:global:apprendasession)) {
            throw "No current Apprenda Session found.  Aborting."
        } 

        $url = "$($apprendaSession.url)/soc/api/v1/addons/$Alias"
                       
        # See http://social.technet.microsoft.com/wiki/contents/articles/29863.powershell-rest-api-invoke-restmethod-gotcha.aspx
        $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($url)
        $response = Invoke-RestMethod `
            -Method Get `
            -Uri $url `
            -Headers $apprendaSession.headers
        $ServicePoint.CloseConnectionGroup("")

        return $response
    }
}
