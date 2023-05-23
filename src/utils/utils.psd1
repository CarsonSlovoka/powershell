@{
ModuleVersion = '1.0'
GUID = '2432a36a-1ab4-4437-9d4a-42a39cbec727'
Author = 'Carson'
CompanyName = ''
Copyright = 'Copyright (c) 2023 Carson, all right reserved'
Description = 'Open the UI'
NestedModules = @(
    'wifi.psm1',
    "init.psm1",
    "cmd.psm1"
)
# FunctionsToExport 一定要寫，除非你是Import-Module手動載入psm1，那麼可以靠psm1中使用Export-ModuleMember，但如果要仰賴psd1加入psm1的函數一定要寫FunctionsToExport
FunctionsToExport = @(
    # wifi
    'Get-WiFyPassword',
    'Get-WiFiPassword',

    # init
    'MyHelp',

    # cmd
    'Set-ByPass'
)
VariablesToExport = '*' # 還是要手動Import-Module才可以使用該變數
# VariablesToExport = @( # 不需要個別導入，因為只有Export-ModuleMember -Variable中的項目，並非所有psm1的變數都會導入
#     'Author' # 要透過Import-Module ".../xxx.psd1" 導入之後才能用，不會自動導入
# )
CmdletsToExport = @()
AliasesToExport = @(
    # init
    'mh',

    # cmd
    'byPass',

    # wifi
    'gWiPsw',
    'Get-WiFlyPassword'
)
PrivateData = @{
    PSData = @{
    }
}
}

