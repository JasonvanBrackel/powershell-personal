function RunLastCommandUnderSudo  
{
    $cmd = (Get-History ((Get-History).Count))[0].CommandLine
    Write-Host "Running $cmd at $pwd"
    sudo powershell -Command "pushd '$PWD'; Write-host 'sudo $cmd'; $cmd"
}

function Sudo  
{
    if($args[0] -eq '!!') {
        RunLastCommandUnderSudo;
    }
    else {
        $type = Get-CalledCommandType $args[0];
        $isApplication = ($type -eq [System.Management.Automation.CommandTypes]::Application)
        $file, [string]$arguments = $args;
        if($isApplication) {
            $psi = new-object System.Diagnostics.ProcessStartInfo $file   
            $psi.Arguments = $arguments                 
        } else {
            $psi = New-Object System.Diagnostics.ProcessStartInfo "Powershell"
            $psi.Arguments = "-Command `"$file $arguments`""
        }
        $psi.UseShellExecute = $true
        $psi.Verb = "runas"
        $psi.WorkingDirectory = Get-Location
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $psi
        $p.Start() | Out-Null
        $p.WaitForExit()
    }
}

function Get-CalledCommandType ($calledCommand) {
    return (Get-Command $calledCommand).CommandType
}