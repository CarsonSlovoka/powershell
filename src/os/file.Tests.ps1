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
