@{
    ModuleVersion = '1.0'
    # Microsoft.PowerShell.Utility\New-Guid
    GUID = '999def71-b05d-4a4a-a70e-7cb4c93ecf28'
    Description = ''
    PowerShellVersion = '6.2'
    NestedModules = @(
        'json.psm1'
    )
    FunctionsToExport = @(
        # json.psm1
        'Convert-Json5ToJson'
    )
    AliasesToExport = @(
        # json.psm1
        'json5Tojson', 'j5Toj', 'j52j' # 'Convert-Json5ToJson'
    )
    VariablesToExport = '*'
    CmdletsToExport = @()
    PrivateData = @{
        PSData = @{}
    }
}

