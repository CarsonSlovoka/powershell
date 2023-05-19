# powershell

一些簡單的腳本，幫助您工作更有效率

## Install

只要將本專案的src目錄告知給環境變數: `PSModulePath` 之後打開powershell即可開始使用，

如果您想要使用UI加入可以透過SystemPropertiesProtection.exe來加入

> start $env:SystemRoot\System32\SystemPropertiesProtection.exe # 可以快速開啟env的設定

如果您想使用腳本來安裝，可以點擊[install.bat](install.bat) (需安裝`pwsh.exe`)

因為powershell5.1預設不是使用UTF8，所以運行的時候，遇到腳本的中文可能會有問題，建議您安裝powershell7，取得`pwsh.exe`

取得`pwsh.exe`和安裝:

1. 開啟powershell，輸入指令: `winget install --id Microsoft.Powershell --source winget`
  - 會安裝在: `%ProgramFiles%\PowerShell\7\pwsh.exe`
  - 查看powershell相關應用程式的位置: `gcm powershell, pwsh`
2. 點擊[install.bat](install.bat)
