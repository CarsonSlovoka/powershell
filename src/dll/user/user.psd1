@{
ModuleVersion = '1.0'
# Microsoft.PowerShell.Utility\New-Guid
GUID = 'd35c9170-99ac-4c89-b889-634927203c55'
Author = 'Carson'
CompanyName = ''
Copyright = 'Copyright (c) 2023 Carson, all right reserved'
Description = 'user32dll'
NestedModules = @(
    'messagebox.psm1',
    'window.psm1'
)

# 注意裡面的成員是字串，如果少加'，會出現錯誤: The command 'xxx' is not allowed in restricted language mode or a Data section.
FunctionsToExport = @(
    'MessageBox',

    'Show-WindowAsync'
)
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @(
    'swa',
    'showWinA'
)
PrivateData = @{
    PSData = @{
    }
}
}

