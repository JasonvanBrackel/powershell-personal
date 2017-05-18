
function New-FakeObjectCollection
(
    [string]$name,
    [string]$path
) {
    $count = Get-Random -Minimum 1 -Maximum 5
    $list = @()
    for ($index = 1; $index -le $count; $index++) {
        $folderPath = "$path\$([System.IO.Path]::GetRandomFileName())"
        New-FakeFolder $folderPath | Out-Null
        $list += ([pscustomobject]@{ Name = "$name$index"; Path = $folderPath})
    }

    return $list
}

function New-FakeFileCollection
(
    [string]$path
) {
    $count = Get-Random -Minimum 1 -Maximum 5
    $list = @()
    for ($index = 1; $index -le $count; $index++) {
        $filePath = "$path\$([System.IO.Path]::GetRandomFileName())"
        New-Fakefile $filePath | Out-Null
        $list += $filePath
    }

    return $list
}

function New-Fakefile
(
    [string]$path
) {
    New-Item -ItemType File -Path $path  
    Set-Content -Path $path -Value ( -join ((65..90) + (97..122) | Get-Random -Count (Get-Random -Maximum 40000) | % {[char]$_}))
}

function New-FakeFolder
(
    [string]$path
) {
    New-Item $path -ItemType directory
    $fakeFileCount = Get-Random -Minimum 1 -Maximum 5

    (1..$fakeFileCount) | New-Fakefile -path "$path\$([System.IO.Path]::GetRandomFileName())"
}

function Assert-FilesAreTheSame
(
    [string]$OriginalFolder,
    [string]$DestinationFolder,
    [string]$FileName
) {
    $originalFile = "$OriginalFolder\$FileName"
    $destinationFile = "$DestinationFolder\$FileName"
    (Get-Content $destinationFile) | Should Be (Get-Content $originalFile)
}

function Assert-OriginalFilesAreIncludedInDestination 
(
    [string]$OriginalFolder,
    [string]$DestinationFolder
) {
    foreach($file in (Get-ChildItem $OriginalFolder)) {
        Assert-FilesAreTheSame -OriginalFolder $OriginalFolder -DestinationFolder $DestinationFolder -FileName $file.Name
    }
    
}

function New-MockApprendaSession {
    $fakeSession = @{
        url = "https://fake"
        username = "fakeUser"
        password = ("fakePassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
        tenantAlias = "fakeTenant"
        sessionToken = "fakeSessionToken"
        headers = @{
            "Content-Type"="application/json" 
            "ApprendaSessionToken"="fakeSessionToken"
            "charset"="UTF-8" 
        }
        isFake = $true
    }
    Set-Variable -Scope Global -Name apprendaSession -Value $fakeSession
    return $fakeSession
}