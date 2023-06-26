Describe "json.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'encoding.psd1')
    }

    It "Calls Convert-Json5ToJson" {
        Wait-Debugger
        # 純轉換
        $json5Path = Join-Path $PSScriptRoot 'testFiles/test.json5'
        $o = Convert-Json5ToJson $json5Path
        $o.Err | Should -Be $null
        $o.Value.cmd | Should -Be "Run"
        (Compare-Object $o.Value.datas @(1, 2, 3)) | Should -Be $null # 完全相同

        # 保存到另一個檔案
        $outPath = Join-Path $PSScriptRoot "temp.json"
        $o = Convert-Json5ToJson $json5Path $outPath
        $o.Err | Should -Be $null
        Test-Path $outPath | Should -Be $true
        $obj = Get-Content $outPath | ConvertFrom-Json
        $obj.cmd | Should -Be "Run"
        (Compare-Object $obj.datas @(1, 2, 3)) | Should -Be $null
        Remove-Item $outPath -ErrorAction SilentlyContinue

        # 測試來源檔案不存在
        $o = Convert-Json5ToJson "notExistsJson"
        $o.Err | Should -Not -BeNullOrEmpty
    }
}
