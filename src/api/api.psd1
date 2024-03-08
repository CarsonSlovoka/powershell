@{
ModuleVersion = '1.0'
# Microsoft.PowerShell.Utility\New-Guid
GUID = '63154f9a-e197-4121-9747-b45969802244'
Description = ''
PowerShellVersion = '7.0'
NestedModules = @(
    'openai.psm1'
)
FunctionsToExport = @(
    # openai.psm1
    'Request-OpenAI-Help',
    'Request-OpenAI-OpenPlayground',
    'Request-OpenAI-ListThread',
    'Request-OpenAI-GetThreads',
    'Request-OpenAI-GetThreadMsg',
    'Request-OpenAI-DeleteThread'
)
AliasesToExport = @(
)
VariablesToExport = '*'
CmdletsToExport = @()
PrivateData = @{
    PSData = @{}
}
}
