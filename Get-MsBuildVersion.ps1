

<#
    .SYNOPSIS
        Gets a list of MSBuild versions installed on the machine

    .DESCRIPTION
        Reads from the machine's registry and serializes the keys into an easily digestible format.

    .PARAMETER VersionNumber
        When used returns the data for a single version of MSBuild installed on the machine or null if the version doesn't exist

    .EXAMPLE
        Gets all versions of MSBuild installed on the machine
        Get-MsBuildVersion
    
    .EXAMPLE
        Gets a specific version of MSBuild installed on the machine
        Get-MsBuildVersion -Version 14.0

#>
function Get-MsBuildVersion {
    [CmdletBinding()]
    param(
        [string]$Version = ""
    )
    process {
        $decimalSeperator = [System.Threading.Thread]::CurrentThread.CurrentUICulture.NumberFormat.CurrencyDecimalSeparator;
        $versions = $(
            Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions\" |
            ? { $_.Name -match '\\\d+.\d+$' } |
            Sort-Object -property  @{Expression={[System.Convert]::ToDecimal($_.Name.Substring($_.Name.LastIndexOf("\") + 1).Replace(".",$decimalSeperator).Replace(",",$decimalSeperator))}} -Descending
        )

        if($versions -ne $null) {
            if(![string]::IsNullOrWhiteSpace($Version)) {
                if($Version -eq "Latest") {
                    return $versions | Select-Object -First 1
                }
                return $versions | ? { $_.Name -like "*$Version" } | Select-Object -First 1
            } 
        }

        return $versions
    }   
}
