@{
    ModuleVersion = '1.0'
    # Microsoft.PowerShell.Utility\New-Guid
    GUID = '2108bca5-0a08-4b3f-a968-5002aae09601'
    Author = 'Carson'
    CompanyName = ''
    Copyright = 'Copyright (c) 2023 Carson, all right reserved'
    Description = 'coverage'
    NestedModules = @(
        'lcov.psm1'
    )

    FunctionsToExport = @(
        'Convert-LCovToHtml'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
        }
    }
}
