Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ApprendaAddOnInstance {
    <# 
        .SYNOPSIS
            Gets an instance of a deployed add on for a development team
        .PARAMETER Alias
            Alias of the AddOn as set in the Apprenda SOC
        .PARAMETER InstanceAlias
            Name for the instance of the add on
        .LINK
            Provisioning and Consuming Add-Ons
            http://docs.apprenda.com/current/addonconsumption
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Alias,
        [Parameter(Mandatory=$true)]
        [string]$InstanceAlias
    )
    
    process {
        if (!(Test-Path variable:global:apprendasession)) {
            throw "No current Apprenda Session found.  Aborting."
        } 

        $url = "$($apprendaSession.url)/developer/api/v1/addons/$Alias/$InstanceAlias"

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
