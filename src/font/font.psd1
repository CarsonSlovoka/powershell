@{
ModuleVersion = '1.0'
# Microsoft.PowerShell.Utility\New-Guid
GUID = 'a1a3695a-7360-42e6-a939-b6ffb704c91a'
Description = ''
PowerShellVersion = '6.0'
NestedModules = @(
    'font.psm1',
    'info.psm1'
)
FunctionsToExport = @(
    # font.psm1
    'Save-FontChars',
    'Export-GlyphToExcel',

    # info.psm1
    'Get-GlyphTypeface',
    'Get-InstallGlyphTypeface'
)
AliasesToExport = @()
VariablesToExport = '*'
CmdletsToExport = @()
PrivateData = @{
    PSData = @{}
}
}

