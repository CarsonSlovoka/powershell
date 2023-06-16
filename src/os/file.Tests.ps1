Describe "os.file.psd1 Get-Help" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
    }

    It "Calls Get-Help Remove-NotInListFiles -Full" {
        InModuleScope os {
            # [PSCustomObject] $result = Get-Help Remove-NotInListFiles -Full # 預設是PSCustomObject，這個的Length不符合我們所預期;
            [string] $result = Get-Help Remove-NotInListFiles -Full
            ($result.Length -gt 0) | Should -Be $true
        }
    }
}

# function Create-SampleDir {} # 函數寫在外層，沒辦法給It裡面用，他們是隔離開來的;

Describe "Remove-NotInListFiles" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
        $wkDir = Join-Path $PSScriptRoot "temp"
        $srcLst = Join-Path $PSScriptRoot "src.lst"
        $LF = "`n"

        function Watch-WkDir {
            return @(
                (Test-Path (Join-Path $wkDir "1Keep.png")),
                (Test-Path (Join-Path $wkDir "11.png")),
                (Test-Path (Join-Path $wkDir "111Keep.png")),
                (Test-Path (Join-Path $wkDir "sub/2.png")),
                (Test-Path (Join-Path $wkDir "sub/2Keep.txt")),
                (Test-Path (Join-Path $wkDir "sub/2.xml"))
            )
        }
    }

    BeforeEach {
        # Create-SampleDir
        # Wait-Debugger
        $srcContent = @(
            '1Keep.png',
            '111Keep.png',
            '2Keep.txt'
        ) -Join $LF

        # 建立lst檔案;
        Set-Content $srcLst -Value $srcContent -Force -Encoding utf8

        # temp
        New-Item $wkDir -ItemType Directory -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "1Keep.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "11.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "111Keep.png") -ErrorAction SilentlyContinue

        # temp/sub
        New-Item (Join-Path $wkDir 'sub') -ItemType Directory -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/2.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/2Keep.txt") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/2.xml") -ErrorAction SilentlyContinue
    }

    It 'Calls Remove-NotInListFiles $srcLst $wkDir' {
        # Wait-Debugger
        Remove-NotInListFiles $srcLst $wkDir
        Watch-WkDir | Should -Be @(
            $true,  # 1Keep.png
            $false, # 11.png
            $true,  # 111Keep.png

            # 沒有recurse，所以sub的目錄沒有被更動理應當都在;
            $true, # sub/2.png
            $true, # sub/2Keep.txt
            $true  # sub/2.xml
        )
    }

    It 'Calls Remove-NotInListFiles $srcLst $wkDir -recurse' {
        Remove-NotInListFiles $srcLst $wkDir -recurse
        Watch-WkDir | Should -Be @(
            $true,  # 1Keep.png
            $false, # 11.png
            $true,  # 111Keep.png

            $false, # sub/2.png
            $true,  # sub/2Keep.txt
            $false  # sub/2.xml
        )
    }

    It 'Calls Remove-NotInListFiles $srcLst $wkDir -recurse -filter *.png' {
        Remove-NotInListFiles $srcLst $wkDir -recurse -filter *.png
        # filter為png，所以只有png可能被異動，非png的檔案原封不動(必定存在);
        Watch-WkDir | Should -Be @(
            $true,  # 1Keep.png
            $false, # 11.png
            $true,  # 111Keep.png

            $false, # sub/2.png

            # ↓ 由於-filter *.png，所以非png的檔案一定不動，會存在;
            $true,  # sub/2Keep.txt
            $true   # sub/2.xml
        )
    }

    AfterAll {
        # Wait-Debugger
        # Remove-Item $wkDir -Recurse -WhatIf
        Remove-Item $wkDir -Recurse
        Remove-Item $srcLst
    }
}

Describe "Rename-WithSerialNumber" {
    $wkDir = Join-Path $PSScriptRoot "temp" # It的變數會受到這個影響，不受到BeforeAll影響

    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
        $wkDir = Join-Path $PSScriptRoot "temp" # 在It裡面的變數與外層的變數是獨立開來的，所以要在BeforeAll宣告
        $outputFile = "temp.result.csv"
    }

    BeforeEach {
        # 每次都清除工作目錄，避免受到上個流程的結果影響
        if (Test-Path -Path $wkDir) {
            Remove-Item $wkDir -Recurse
        }

        if (Test-Path $outputFile) {
            Remove-Item $outputFile
        }

        # temp
        # 注意: 我們使用CreationTime來排序，所以創建的順序會影響到結果
        New-Item $wkDir -ItemType Directory -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "1_copy.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "1.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "a.png") -ErrorAction SilentlyContinue

        # temp/sub
        New-Item (Join-Path $wkDir 'sub') -ItemType Directory -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/c.png") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/d.txt") -ErrorAction SilentlyContinue
        New-Item (Join-Path $wkDir "sub/e.xml") -ErrorAction SilentlyContinue
    }

    It "Calls Rename-WithSerialNumber -wkDir $wkDir -filter *.png" {
        $o = Rename-WithSerialNumber -wkDir NotExistDir -filter *.png
        $o.Err | Should -Not -BeNullOrEmpty # 檔案不存在，所以會報錯;

        $o = Rename-WithSerialNumber -wkDir $wkDir -filter *.png
        $o.Err | Should -Be $null
        $o.Datas.Length | Should -Be 3

        # 檔案數量應一樣;
        (Get-ChildItem $wkDir -Recurse).Length | Should -Be 7 # 6檔案+1資料夾;

        @(
            (Test-Path (Join-Path $wkDir "1_copy.png")), # => (已存在) 1.png => (已存在) 1_copy.png => 1_copy_copy.png;
            (Test-Path (Join-Path $wkDir "1_copy_copy.png")),
            (Test-Path (Join-Path $wkDir "1.png")), # 2.png
            (Test-Path (Join-Path $wkDir "2.png")),
            (Test-Path (Join-Path $wkDir "a.png")), # 3.png
            (Test-Path (Join-Path $wkDir "3.png"))

            (Test-Path (Join-Path $wkDir "sub/c.png")),
            (Test-Path (Join-Path $wkDir "sub/d.txt")),
            (Test-Path (Join-Path $wkDir "sub/e.xml"))
        ) | Should -Be @(
          $false,
          $true  ,

          $false
          $true,

          $false,
          $true,

          # 因為沒有recurse，所以其他子目錄不異動;
          $true
          $true
          $true
        )
    }

    It "Calls Rename-WithSerialNumber -wkDir $wkDir -filter *.png -recurse" {
        $o = Rename-WithSerialNumber -wkDir $wkDir -filter *.png -recurse
        $o.Err | Should -Be $null
        $o.Datas.Length | Should -Be 4 # temp 3個檔案 + 子資料夾sub的1個檔案

        # 檔案數量應一樣
        (Get-ChildItem $wkDir -Recurse).Length | Should -Be 7 # 6檔案+1資料夾;

        @(
            (Test-Path (Join-Path $wkDir "1_copy.png")), # => (已存在) 1.png => (已存在) 1_copy.png => 1_copy_copy.png;
            (Test-Path (Join-Path $wkDir "1_copy_copy.png")),
            (Test-Path (Join-Path $wkDir "1.png")), # 2.png
            (Test-Path (Join-Path $wkDir "2.png")),
            (Test-Path (Join-Path $wkDir "a.png")), # 3.png
            (Test-Path (Join-Path $wkDir "3.png"))
            (Test-Path (Join-Path $wkDir "sub/c.png")), # 4.png
            (Test-Path (Join-Path $wkDir "sub/4.png")),
            (Test-Path (Join-Path $wkDir "sub/d.txt")),
            (Test-Path (Join-Path $wkDir "sub/e.xml"))
        ) | Should -Be @(
          $false,
          $true ,

          $false
          $true,

          $false,
          $true,

          $false
          $true

          # ↓ 非篩選的檔案不異動;
          $true
          $true
        )

        (Test-Path $outputFile) | Should -Be $false # 因為我們前面都沒有補上-outputFile，所以輸出的結果都不會產生出檔案才對

        # test output file
        $o = Rename-WithSerialNumber -wkDir $wkDir -filter *.png -outputFile $outputFile
        Test-Path $outputFile | Should -Be $true
    }

    AfterAll {
        Remove-Item $wkDir -Recurse
        Remove-Item $outputFile -ErrorAction SilentlyContinue # 避免測試案例在最後一個而沒有把測試檔案刪除的狀況發生;
    }
}

Describe "Rename-FileByList" {
    $wkDir = Join-Path $PSScriptRoot "temp"
    $testFilesDir = Join-Path $wkDir "testFiles"
    $srcLst = Join-Path $wkDir "src.lst"

    BeforeAll {
        $LF = "`n"
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
        $wkDir = Join-Path $PSScriptRoot "temp"

        $srcLst = Join-Path $wkDir "src.lst"
        $testFilesDir = Join-Path $wkDir "testFiles" # 模擬要被重新命名的文件

        # 建立工作目錄
        # temp
        New-Item $wkDir -ItemType Directory -ErrorAction SilentlyContinue
        # temp/testFiles
        New-Item $testFilesDir -ItemType Directory -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Out-File $srcLst -Encoding utf8NoBOM # 創建或者清除src.lst的內容

        # 清除所有被模擬的文件，避免因為測試案例的殘留
        Remove-Item $testFilesDir -Recurse

        # 清除之後重建，此時此目錄應為空
        New-Item $testFilesDir -ItemType Directory -ErrorAction SilentlyContinue
    }

    It "Rename-FileByList -srcLst $srcLst -wkDir $testFilesDir -ext .png" {
        # 建立lst檔案
        $srcContent = @(
            'old-01 new-01',
            'old-02 new-02'
        ) -Join $LF
        Set-Content $srcLst -Value $srcContent -Force -Encoding utf8

        # 創建測試檔案
        Out-File (Join-Path $testFilesDir "old-01.png") -Encoding utf8NoBOM
        Out-File (Join-Path $testFilesDir "old-02.png") -Encoding utf8NoBOM

        $o = Rename-FileByList $srcLst -wkDir $testFilesDir -ext ".png"
        $o.Err | Should -BeNullOrEmpty
        $o.Count | Should -Be 2

        @(
            (Test-Path (Join-Path $testFilesDir "old-01.png")),
            (Test-Path (Join-Path $testFilesDir "old-02.png")),
            (Test-Path (Join-Path $testFilesDir "new-01.png")),
            (Test-Path (Join-Path $testFilesDir "new-02.png"))
        ) | Should -Be @(
            $false,
            $false,
            $true,
            $true
        )
    }

    It "Rename-FileByList -srcLst $srcLst -sep ," {
        # srcLst寫完整路徑的測試
        $srcContent = @(
            "$(Join-Path $testFilesDir old-01.png),$(Join-Path $testFilesDir new-01.bmp)",
            "$(Join-Path $testFilesDir old-02.png),$(Join-Path $testFilesDir new-02.svg)"
        ) -Join $LF
        Set-Content $srcLst -Value $srcContent -Force -Encoding utf8

        # 創建測試檔案
        Out-File (Join-Path $testFilesDir "old-01.png")
        Out-File (Join-Path $testFilesDir "old-02.png")

        # $o = Rename-FileByList $srcLst -sep "|" # `|` 會有另外的解讀，所以不行用
        $o = Rename-FileByList $srcLst -sep ","
        $o.Err | Should -BeNullOrEmpty
        $o.Count | Should -Be 2

        @(
            (Test-Path (Join-Path $testFilesDir "old-01.png")),
            (Test-Path (Join-Path $testFilesDir "old-02.png")),
            (Test-Path (Join-Path $testFilesDir "new-01.bmp")),
            (Test-Path (Join-Path $testFilesDir "new-02.svg"))
        ) | Should -Be @(
            $false,
            $false,
            $true,
            $true
        )
    }

    AfterAll {
        Remove-Item $wkDir -Recurse
    }
}
