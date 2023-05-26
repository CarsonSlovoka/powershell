Describe "Test calendar.calendar.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'calendar.psd1')
    }

    It "Calls Test-IsAdministrator one month" {
        $r = Show-Calendar (New-Object DateTime 2023,5,2)
        $r.GetType().Name | Should -Be "String"
        $r.Length | Should -BeGreaterThan 30 # 每一個月的內容，文字內容有1~31總長度肯定大於30;
    }

    It "Calls Test-IsAdministrator range: 2023/5/2~2023/8/8" {
        [System.Array]$r = Show-Calendar (New-Object DateTime 2023,5,2) (New-Object DateTime 2023,8,8)
        $r.Length | Should -Be 4 # 有4個月(5~8含)，因此4個;
    }
}
