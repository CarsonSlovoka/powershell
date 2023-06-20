Describe "[font.psd1.font.psm1]" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'font.psd1')
        $wkDir = Join-Path $PSScriptRoot "temp"
        New-Item $wkDir -ItemType Directory -ErrorAction SilentlyContinue
        $fontPath = Join-Path $env:SystemRoot fonts/Arial.ttf
        $testFontPath = Join-Path $PSScriptRoot "testFiles/carson.ttf"
        $outputFilePath = Join-Path $wkDir out.txt
    }

    BeforeEach {
        Out-File $outputFilePath -Encoding utf8NoBOM # 利用創建檔案來清空文件內容
    }

    It "Calls Save-FontChars -autoIdx" {
        Save-FontChars $testFontPath $outputFilePath -autoIdx -fontSize 18 -bitmapSize 32 -savePicture
        [Object[]]$datas = Get-Content $outputFilePath
        $datas.Length | Should -Be 1 # 只需要1列
        $datas -Join "" | Should -Be "BD"

        # 輸出的圖片應該要存在
        @(
            (Test-Path (Join-Path $wkDir "0042.png")),
            (Test-Path (Join-Path $wkDir "0044.png"))
        ) | Should -Be @(
            $true,
            $true
        )
    }

    It "Calls Save-FontChars" {
        if (!(Test-Path $fontPath)) { # 不確定github action的windows系統有沒有預設的Arial字型，所以用這樣確保
            return
        }
        # 目標為A~Z共26個字母
        Save-FontChars $fontPath $outputFilePath -startIdx 65 -endIdx 0x5B -fontSize 48 -bitmapSize 72
        [Object[]]$datas = Get-Content $outputFilePath
        $datas[0].Length | Should -Be 10 # 每列10個字
        $datas.Length | Should -Be 3 # 26個字母所以會有3列
        $datas -Join "" | Should -Be "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    It "Calls Save-FontChars with -savePicture" {
        if (!(Test-Path $fontPath)) {
            return
        }
        Save-FontChars $fontPath $outputFilePath -startIdx 0x1F44C -endIdx 0x1F44E -fontSize 48 -bitmapSize 72 -savePicture
        # 0x1F44C 👌
        # 0x1F44D 👍
        [Object[]]$datas = Get-Content $outputFilePath
        $datas.Length | Should -Be 1 # 只有兩個字，所以只需要1列(每列10個字)
        $datas -Join "" | Should -Be "👌👍"
        # 輸出的圖片應該要存在
        @(
            (Test-Path (Join-Path $wkDir "1F44C.png")),
            (Test-Path (Join-Path $wkDir "1F44D.png"))
        ) | Should -Be @(
            $true,
            $true
        )
    }

    It "Calls Export-GlyphToExcel" {
        $excelExe = Get-Command "excel" -ErrorAction SilentlyContinue
        if ($excelExe -eq $null) {
            Write-Host "excel.exe not found"
            return
        }

        if (!(Test-Path $fontPath)) { # 不確定github action的windows系統有沒有預設的Arial字型，所以用這樣確保
            return
        }

        $chars = @(
            @('中',[char]::ConvertFromUtf32(0x597D)),
            @('A', 0x41, 65, '您', '好', "多字", "Good")
        )
        # Import-Module (Join-Path ($PSScriptRoot | Split-Path) 'os/process.psm1') # Stop-ProcessByName
        # Stop-ProcessByName "excel" # 先關閉所有excel程序
        Export-GlyphToExcel $fontPath (Join-Path $wkDir "outWithLabel.xlsx") $chars -fontSize 12 -label
        # 很奇怪，兩個連著做就會遇到錯誤: 無法取得類別 Worksheet 的 Paste 屬性
        # Stop-ProcessByName "excel" # COM的退出似乎有BUG，所以強制關閉，避免再次調用時會發生問題
        # Export-GlyphToExcel $fontPath (Join-Path $wkDir "out.xlsx") $chars -fontSize 12 # COMException: 無法取得類別 Worksheet 的 Paste 屬性
        # Stop-ProcessByName "excel"
        @(
            (Test-Path (Join-Path $wkDir "outWithLabel.xlsx"))
            # (Test-Path (Join-Path $wkDir "out.xlsx"))
        ) | Should -Be @(
            $true
            # $true
        )
    }

    AfterAll {
        Remove-Item $wkDir -Recurse
    }
}
