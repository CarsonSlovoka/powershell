# pwsh

powershell5用的不是UTF8，所以運行的時候，遇到腳本的中文可能會有問題，powershell7開始都是UTF-8的編碼，會好很多

## Install

取得`pwsh.exe`

開啟powershell，輸入指令: `winget install --id Microsoft.Powershell --source winget`即可完成安裝。

- 預設安裝的路徑在: `%ProgramFiles%\PowerShell\7\pwsh.exe`
- 查看powershell相關應用程式的位置: `gcm powershell, pwsh`

## Update

如果pwsh的版本有更新，可以訪問該release的頁面，以7.3.5的版本為例:
> https://github.com/PowerShell/PowerShell/releases/tag/v7.3.5

如果是windows, 64，可以選擇`PowerShell-7.3.5-win-x64.zip`下載

之後解壓縮，將裡面的檔案全部放到`$PSHome`<sup>`C:\Program Files\PowerShell\7`</sup>資料夾裡面即可。
> 您可以直接把原本`$PSHome`目錄重新命名當作備份以防萬一
