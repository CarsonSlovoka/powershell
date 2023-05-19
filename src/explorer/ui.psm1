<#
.Synopsis
    列出 "$env:SystemRoot\system32" 常用的工具，幫助您快速開啟
.Parameter programName
    - taskmgr 工作管理員
    - perfmon 資源檢視器
    - taskSchd 工作排程器
#>
function Open-SystemTool {
    param (
        [ValidateSet(
            'taskmgr.exe',
            'taskSchd.msc',
            'perfmon.exe'
        )]
        [string]$programName
    )
    $programName | Invoke-Expression
}
