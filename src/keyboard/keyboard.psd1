@{
    ModuleVersion = '1.0'
    # Microsoft.PowerShell.Utility\New-Guid
    GUID = '1097c254-85b8-4370-845e-6afd08222b05'
    Description = ''
    NestedModules = @(
        'clipboard.psm1'
    )
    FunctionsToExport = @(
        # clipboard.psm1
        'Save-ClipboardImage',
        'Show-ClipboardHistory',
        'Watch-ClipboardImage'
    )
    AliasesToExport = @(
    )
    VariablesToExport = '*'
    CmdletsToExport = @()
    PrivateData = @{
        PSData = @{}
    }
}

