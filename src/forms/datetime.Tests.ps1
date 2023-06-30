Describe "datetime.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'forms.psd1')
    }

    <# 此方法無效，會有未知錯誤
    It "Calls Show-DateTime" {
        if ($PSVersionTable.PSVersion.Major -eq 5) { # 沒有InvokeAsync
            return
        }

        # 建立一個異步的程序，來強制關閉
        $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $runspace.Open()

        $powerShell = [PowerShell]::Create()
        $powerShell.Runspace = $runspace
        $powerShell.AddScript("Show-DateTime")
        $r = $PowerShell.InvokeAsync() # Powershell 5沒有InvokeAsync
        # $r.IsCompleted
        # $r.Result
        Start-Sleep -Seconds 2 # 等待運行
        $powerShell.Dispose() # 強制關閉
        $runspace.Dispose()
    }
    #>

    It "Calls Set-Countdown 3 -opacity 0.4 -dangerCriteria 2 -topMost" {
        $o = Set-Countdown 3 -opacity 0.4 -dangerCriteria 2 -topMost
        $o | Should -Be $null
    }

    It "Calls Set-Countdown 3 -opacity 30 should get the error" {
        $msg = ""
        try {
            Set-Countdown 3 -opacity 30
        } catch {
            $msg = $_.Exception.Message
        }
        # $msg | Should -Be "Invalid Opacity value. should be 0~1." # 無法驗證 'opacity' 參數上的引數。 ... 它會多出前面的部分，而該部分依據電腦語系而有所不同
        $msg.Contains("Invalid Opacity value. should be 0~1.") | Should -Be $true
    }
}
