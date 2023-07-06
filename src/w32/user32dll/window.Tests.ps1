Describe "user32dll.psd1.window.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'window.psm1')
    }

    It "Calls Set-Countdown 3 -opacity 0.4 -dangerCriteria 2 -topMost" {
        Start-Process powershell.exe
        $o = Find-Window 'ConsoleWindowClass' 'Windows PowerShell'
        $o.Hwnd | Should -Not -BeNullOrEmpty
        $o = Find-Window 'ConsoleWindowClass'
        $o.Hwnd | Should -Not -BeNullOrEmpty
        $o = Find-Window -windowName 'Windows PowerShell'
        $o.Hwnd | Should -Not -BeNullOrEmpty

        $o = Find-Window 'Not exists class Name' 'Not exists window Name'
        $o.Err | Should -Not -BeNullOrEmpty

        $o = Find-Window 'Not exists class Name'
        $o.Err | Should -Not -BeNullOrEmpty

        $o = Find-Window -windowName 'Not exists window Name'
        $o.Err | Should -Not -BeNullOrEmpty
    }
}
