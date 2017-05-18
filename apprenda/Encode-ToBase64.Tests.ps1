$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\Test-Helpers.ps1"

Describe "Encode-ToBase64" {
    #Mock a file
    $expectedPath = "$TestDrive\archive.zip"
    New-FakeFile $expectedPath
    $expectedOutput = [System.Convert]::ToBase64String((Get-Content $expectedPath -Encoding Byte))
   
    $result = Encode-ToBase64 $expectedPath

    It "should return the encoded string" {
        $result | Should Be $expectedOutput
    }
}
