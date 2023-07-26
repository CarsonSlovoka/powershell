function Stop-ProcessByName {
    <#
    .Description
        強制關閉所有符合的名稱項目其程序
    .Example
        Stop-ProcessByName excel
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$name
    )
    # $process = Get-process -Name $name -ErrorAction SilentlyContinue
    $process = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($process -eq $null) {
        Write-Verbose "$name not found"
        return
    }
    $process | ForEach-Object {Stop-Process -Id $_.Id}
}

function Watch-IsAlive {
    <#
    .Description
        檢查某應用程式是否還活著
    .Parameter processName
        應用程式名稱，不需要加上.exe
    .Parameter interval
        每間隔多久確認一次, 單位:秒
    .Example
        Watch-IsAlive notepad 5
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$processName,
        [Parameter(Mandatory)]
        [int]$interval
    )

    $now = "{0:yyyy-MM-dd hh:mm:ss}" -f (Get-Date)
    Write-Host "$now Start Watch: " -NoNewLine
    Write-Host $processName -ForegroundColor Yellow -NoNewLine
    Write-Host " is alive..."

    while ($true) {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($process -eq $null) {
            $now = Get-Date
            $nowStr = "{0:yyyy-MM-dd hh:mm:ss}" -f $now
            Write-Host "$nowStr program $processName has been closed."
            return $now
        }
        else {
            Start-Sleep -Seconds $interval
            Write-Verbose "isAlive"
        }
    }
}
