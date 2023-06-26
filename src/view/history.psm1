function Show-History {
    <#
    .Synopsis
        用UI來顯示查找使用過的命令，類似於按「↑」出現的命令
    .Link
        Out-HtmlView: https://github.com/EvotecIT/PSWriteHTML
    #>
    [CmdletBinding()]
    param (
    )
    Get-History | Out-GridView
}
