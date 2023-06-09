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
