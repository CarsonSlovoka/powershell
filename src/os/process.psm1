function Stop-ProcessByName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$name
    )
    # $process = Get-process -Name $name -ErrorAction SilentlyContinue
    $process = Get-Process -Name $name -ErrorAction Stop

    $process | ForEach-Object {
        if ($PSCmdlet.ShouldProcess("Name: $($_.Name) PID: $($_.ID)", "Stop-Process")) {
            Stop-Process -Id $_.Id -F
        } else {
            Stop-Process -Id $_.Id -WhatIf
        }
    }
}
