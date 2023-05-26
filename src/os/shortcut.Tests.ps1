Describe "os.shortcut.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
        $lnkPath = Join-Path $PSScriptRoot "MyPowershell.lnk"
    }

    It "Calls Set-Shortcut" {
        $targetPath = "powershell.exe"
        $wkDir = "C:\ProgramData"
        $arguments = "-msg=`"hello world`""
        $shortcut = Set-Shortcut $lnkPath $targetPath $wkDir $arguments

        $shortcut.Arguments | Should -Be $arguments
        $shortcut.WorkingDirectory | Should -Be $wkDir
        Test-Path $lnkPath | Should -Be $true
    }

    AfterAll {
        Remove-Item $lnkPath -ErrorAction SilentlyContinue
    }
}
