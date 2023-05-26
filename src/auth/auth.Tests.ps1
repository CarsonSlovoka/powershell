Describe "Test auth.auth.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'auth.psd1')
    }

    It "Calls Test-IsAdministrator" {
        $r = Test-IsAdministrator
        $r.Err | Should -Be $null
    }
}
