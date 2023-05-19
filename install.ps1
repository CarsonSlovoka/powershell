function Add-PSModulePath {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$envPath
    )
    Write-Host '在PSModulePath系統路徑添加本腳本的位置' -ForegroundColor Yellow

    # 系統變數powershell 5會在腳本運行的時候自動添加項目，這些額外加入的項目不應該加在系統變數之中，所以跳過
    [int]$skipIndex = 1
    if ($PSVersionTable.PSVersion.Major -eq 7) {
        # 如果是7的版本，又會額外多出兩個
        $skipIndex = 3
    }

    if ($PSCmdlet.ShouldProcess("是否要添加路徑: $envPath ?", "在PSModulePath添加路徑")) {
        [Environment]::SetEnvironmentVariable("PSModulePath", "$envPath;" + [String]::Join(";", (($Env:PSModulePath).split(";") | Select-Object -Skip $skipIndex)), [System.EnvironmentVariableTarget]::Machine)

        # 注意powershell每次啟動之後讀取的環境變數都會寫死，所以即便您已經更改，還是要重新啟動之後才會看到新的路徑，因此底下重新開啟一個powershell
        start powershell.exe "echo 'PSModulePath was updated as follows:'; [System.Environment]::GetEnvironmentVariable('PSModulePath').split(';'); Read-Host 'input any key to exit.'"

        Write-Host '添加成功！' -ForegroundColor Green;
    } else {
        $resultPath = "$envPath;" + [String]::Join(";", (($Env:PSModulePath).split(";") | Select-Object -Skip $skipIndex))
        echo "如果添加成功，則您的PSModulePath會如下所示:"
        $resultPath.split(";")
    }
}

$modulePath = "$PSScriptRoot\src"

$exists = [System.Environment]::GetEnvironmentVariable('PSModulePath').split(';') | foreach { if($_ -eq $modulePath) { return $true } }
if ($exists) {
    Read-Host "您已添加此模塊於PSModulePath，不需要再安裝"
    return
}

try {
    # Add-PSModulePath $modulePath -WhatIf
    Add-PSModulePath $modulePath
} catch {
    Write-Error "需要管理員權限才能運行成功！"
    echo $_.Exception.Message
}
Read-Host "輸入任意鍵離開程式"
