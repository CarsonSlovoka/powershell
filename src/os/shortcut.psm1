<#
.Synopsis
    幫助您創建捷徑
.Parameter filePath
    捷徑要放在哪裡
.Parameter targetPath
    目標程式, 也就是點擊此捷徑實際上會執行哪一隻程式, 圖標會自己設定成該應用程式的圖標. 如果該應用程式無法在系統路徑找到，需要給詳細的路徑位置
.Parameter arguments
    傳遞給目標程式的參數
    如果有需要用到「"」，可以善用跳脫字元「`」
.Parameter workDir
    工作路徑
.Example
    Set-Shortcut "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MyPowershell.lnk" "powershell.exe" "C:\ProgramData" "-msg=`"hello world`""
.Example
    # 執行完之後會開啟捷徑所在目錄
    Set-Shortcut "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MyPowershell.lnk" "powershell.exe" "C:\ProgramData" -openDirWhenFinish 1
#>
function Set-Shortcut {
    param (
        [Parameter(Mandatory=$true)]
        [object]$filePath,
        [Parameter(Mandatory=$true)]
        [string]$targetPath,
        [Parameter(Mandatory=$true)]
        [string]$workDir,
        [Parameter(Mandatory=$false)]
        [string]$arguments,
        [Parameter(Mandatory=$false)]
        [bool]$openDirWhenFinish
    )

    # 確保資料夾存在，如果不存在Get-Item會報錯;
    $fileDir = ($filePath | Split-Path)
    try {
        [System.IO.DirectoryInfo] $fileDir = Get-Item $fileDir
    } catch {
        echo "[Error] $_.Exception.Message"
        Write-Error "請確認$filePath目錄存在"
        return
    }

    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($filePath) # Shortcut.FullName (fullpath), 要存放的路徑
    $shortcut.TargetPath = $targetPath # "powershell.exe" # 執行的目標程式, 如果該應用程式名稱在系統路徑中存在，可以直給名稱即可，他會自己抓到。例如使用powershell.exe，實際會是: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

    $shortcut.Arguments = $arguments
    $shortcut.WorkingDirectory = $workDir
    $shortcut.Save() # 存檔後才會真的產生捷徑

    # Write-Verbose $shortcut # 這個打印的結果不好
    if ($VerbosePreference -eq "Continue") {
        $shortcut
    }

    if ($openDirWhenFinish) {
        start "$($fileDir.FullName)"
    }
}
