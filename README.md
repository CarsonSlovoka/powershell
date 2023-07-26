<p align="center">
  <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3">
      <img src="https://img.shields.io/badge/Made%20with-powershell-0e1620.svg" alt="Made with powershell">
  </a>
  <a href="https://GitHub.com/CarsonSlovoka/powershell/releases/">
      <img src="https://img.shields.io/github/release/CarsonSlovoka/powershell" alt="Latest release">
  </a>
  <a href="https://github.com/CarsonSlovoka/powershell/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/CarsonSlovoka/powershell.svg" alt="License">
  </a>

  <img src="https://img.shields.io/badge/coverage-_68-blue?labelColor=green&color=gray" alt="coverage">
</p>

# ![logo](https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg?sanitize=true) powershell

一些簡單的腳本，幫助您工作更有效率

## Install

有3種方法都可以使用本專案寫的腳本

1. 自行加入系統變數
2. 使用腳本來加入系統變數
3. 使用腳本來安裝(Install by script)

其中1, 2都需自行clone專案，再執行相應動作

### 自行加入系統變數

只要將本專案的src目錄告知給環境變數: `PSModulePath` 之後打開powershell即可開始使用，

如果您想要使用UI加入可以透過SystemPropertiesProtection.exe來加入

```yaml
start $env:SystemRoot\System32\SystemPropertiesProtection.exe # 可以快速開啟env的設定
```

### 使用腳本來加入系統變數

clone專案，之後點擊[install.bat](install.bat)即可 (需安裝[pwsh.exe](docs/pwsh.md#Install)，主要是避免編碼的問題)


### 使用腳本來安裝(Install by script)

你可以打開pwsh.exe直接將[install2.ps1](install2.ps1)的內容貼上也可以安裝

## Usage

所有的指令都寫在[src](src/)的目錄之中，您可以自行逛逛，

大部分的指令都有寫上Help，也都有在裡頭寫Example，所以您都可以透過[Get-Help xxx -full](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.3)來查看用法
