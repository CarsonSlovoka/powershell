@{
ModuleVersion = '1.0'
# Microsoft.PowerShell.Utility\New-Guid
GUID = 'f272e729-96b0-4185-8351-bb01349d3003'
Description = ''
PowerShellVersion = '5.0'
NestedModules = @(
    'mongodb.psm1'
)
FunctionsToExport = @(
    # mongodb.psm1
    'New-MongoConnectByDNS',
    'New-MongoConnectByIP'
)
AliasesToExport = @()
VariablesToExport = '*'
CmdletsToExport = @()
PrivateData = @{
    PSData = @{}
}
}
