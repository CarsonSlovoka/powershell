function Convert-Json5ToJson {
    <#
    .Synopsis
        將json5轉成json，忽略所有註解
    .Example
        ```
        $o = Convert-Json5ToJson "example.json5"
        $o.Value
        ```
    .Example
        Convert-Json5ToJson "example.json5" "out.json"
        j52j "example.json5" "out.json"
    #>
    [alias('json5Tojson', 'j5Toj', 'j52j')]
    param (
        [Parameter(Mandatory)][string] $json5Path,

        [Parameter()][string] $outPath = ""
    )
    $o = @{
        Value = ""
        Err = $null
    }

    try {
        [System.IO.FileSystemInfo] $json5Path = Get-Item $json5Path -ErrorAction Stop
    } catch {
        $o.Err = $_.Exception.Message
        return $o
    }

    # ConvertFrom-Json在舊版的Powershell沒辦法支持json5
    $jsonObj = Get-Content $json5Path | ConvertFrom-Json
    $o.Value = $jsonObj
    if ($outPath -eq "") {
        return $o
    }
    $text = $jsonObj | ConvertTo-Json
    $text | Out-File $outPath #  CREATE | O_TRUNC, utf8NoBOM
    return $o
}
