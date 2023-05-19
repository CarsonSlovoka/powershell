<#
.Synopsis
    重置shell_notifyIcon
.Description
    主要進行以下五個步驟:
    1. HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify
    2. (備份整個TrayNotify資料夾，以防萬一)
    3. 刪除IconStreams, PastIconsStream兩個機碼數值
    4. 開啟工作管理員(taskmgr.exe)，刪除所有explorer.exe的項目
    5. 再次執行explorer.exe
.Example
    # 會提示是否要在刪除前備份
    Reset-ShellNotifyIcon
.Example
    # 強制備份
    Reset-ShellNotifyIcon -backup $true
    Reset-ShellNotifyIcon $true
.Example
    # 不真的執行
    Reset-ShellNotifyIcon -WhatIf
.Link
    https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shell_notifyicona
#>
function Reset-ShellNotifyIcon {
    [CmdletBinding(
         SupportsShouldProcess # -Confirm, -WhatIf
    )]

    param (
        [Parameter(Mandatory=$false)]
        # [bool]$backup = $false # $True, $False, 1, 0
        [bool]$backup # 預設為false
    )

    $RegPath = "HKCU:/SOFTWARE/Classes/Local Settings/Software/Microsoft/Windows/CurrentVersion/TrayNotify"
    $RootKey = "HKCU"
    $SubKey = "SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify"

    $processExplorer = Get-Process -Name "explorer"
    if ($PSCmdlet.ShouldProcess("確定要重建機碼TrayNotify嗎?", "刪除")) {
        if ($backup -or # 我們會視為使用者少打這個參數還是會再詢問;
            ((Read-Host -Prompt "是否要備份?[y/n]")  -eq 'y')) {
            echo "已TrayNotify備份資料，至./TrayNotify.reg"
            # gcm REG # C:\Windows\system32\reg.exe
            echo "$RootKey\$SubKey"
            REG EXPORT "$RootKey\$SubKey" "./TrayNotify.reg" # 反斜線不同會錯誤，他不能使用forward slash
            $backup = $true
            # start . # 這邊打開無效，因為等一下又會關掉所有的explorer
        }
        Remove-ItemProperty -Path $RegPath -Name "IconStreams"
        Remove-ItemProperty -Path $RegPath -Name "PastIconsStream"
        $processExplorer | foreach { Stop-Process -Id "$($_.Id)" } # PID
        explorer.exe

        if ($backup) {
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                start . -Confirm:$false # 不需要confirm
            } else {
                start . # 沒有Confirm的關鍵字
            }
        }
        return
    }

    # ↓ WhatIf
    # Get-ItemProperty -Path $RegPath -Name "IconStreams"
    Remove-ItemProperty -Path $RegPath -Name "IconStreams" -WhatIf
    Remove-ItemProperty -Path $RegPath -Name "PastIconsStream" -WhatIf
    $processExplorer | foreach { Stop-Process -Id "$($_.Id)" -WhatIf } # PID
}
