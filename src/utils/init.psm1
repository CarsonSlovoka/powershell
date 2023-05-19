$Author = "Carson"

function MyHelp {
    param (
        [switch]$NoBrowser
    )
    $myHelpFilePath = Join-Path $PSScriptRoot help.ps1.md
    if ($PSVersionTable.PSVersion.Major -gt 6) {
        if ($NoBrowser) {
            # 直接打印在終端機上, 也是會盡量的突顯, 但效果還是比html差了一點
            $content = Get-Content -Encoding UTF8 (Join-Path $PSScriptRoot help.ps1.md)
            $md = $content | ConvertFrom-Markdown -AsVT100EncodedString
            $md.VT100EncodedString
            return
        }
        Show-Markdown -Path $myHelpFilePath -UseBrowser # 會在%temp%生成一個臨時的html文件
    } else {
        # 因為版本7才有支持Show-Markdown語法，所以低於7就只能以存文本方式顯示
        # Get-Content -Encoding UTF8 $myHelpFilePath # 註解123 如果是ps5的版本，註解不可以打在指令後面，會報錯！
        Get-Content -Encoding UTF8 $myHelpFilePath
    }
}

Set-Alias mh MyHelp
Export-ModuleMember -Function MyHelp -Variable Author -Alias mh
