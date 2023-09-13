@{
ModuleVersion = '1.0'
GUID = '68553c47-a510-43e3-a2f9-8ec516fa0d55'
Author = 'Carson'
CompanyName = ''
Copyright = 'Copyright (c) 2023 Carson, all right reserved'
# 因為預設是用utf16-be編碼，我們改用utf-8所以不要放中文進去，不然會報錯
Description = 'os operator'
NestedModules = @(
    'shortcut.psm1',
    'process.psm1',
    'file.psm1'
)

FunctionsToExport = @(
    # 呼叫可以直接打上指令名稱，也可以加上模組名稱，例如: os\Set-Shortcut
    # shortcut
    'Set-Shortcut',

    # process
    'Stop-ProcessByName',
    'Watch-IsAlive',

    # file
    'Remove-NotInListFiles',
    'Rename-WithSerialNumber',
    'Rename-FileByList',
    'Split-File',
    'Merge-Files'
)
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @()
PrivateData = @{
    PSData = @{
    }
}
}

