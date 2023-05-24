<#
.Synopsis
    讀取字型檔案的每一個碼位，輸出其文字至指定的檔案
.Description
    javascript: escape("風") 可以得知此碼位是: '%u98A8'
.Parameter startIdx
    開始的碼位
.Parameter endIdx
    結束的碼位
    預設值為0x11FFFF，正常來說不應該超過此範圍
.Parameter fontSize
    判斷字的成像是否有內容用
    如果設定太小，畫出來會只有一個點
.Parameter bitmapSize
    判斷字的成像是否有內容用
.Parameter textRenderingHint
    如果要印出比較漂亮的字，要用 [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
.Parameter savePicture
    如果設定會連帶畫出來的圖片一起保存，保存的位子和 outputFile 相同的資料夾
.Example
    Save-FontChars src.ttf out.txt
.Example
    Save-FontChars "C:\xxx\src.ttf" ".\temp\out.txt"
.Example
    Save-FontChars "C:\xxx\src.ttf" "C:\ooo\out.ttf" -endIdx 256 -fontSize 48 -bitmapSize 72 -textRenderingHint ([System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit) -savePicture -Verbose
.Example
    Save-FontChars src.ttf out.txt -endIdx 0x20ffff
    Save-FontChars src.ttf out.txt -startIdx 0xffff -endIdx 0x01ffff
.Example
    Save-FontChars src.ttf out.txt -startIdx 65 -endIdx 128
    Save-FontChars src.ttf out.txt -startIdx 0 -endIdx 65
.Example
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 24 -bitmapSize 48 -savePicture
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 18 -bitmapSize 32 -savePicture # 很輕鬆看出來
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 6 -bitmapSize 9 -savePicture # 免強看出來
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 3 -bitmapSize 6 -savePicture # 很難看出來
.Example
    # RenderHint
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 48 -bitmapSize 72 -textRenderingHint ([System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit) -savePicture
    Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 48 -bitmapSize 72 -savePicture
#>
function Save-FontChars {
    param (
        [Parameter(Mandatory)]
        [string]$srcFile,
        [Parameter(Mandatory)]
        [string]$outputFile,
        [Parameter()]
        [int]$startIdx = 0,
        [Parameter()]
        [int]$endIdx = 0x11FFFF,
        [Parameter()]
        [int]$fontSize=3,
        [Parameter()]
        [int]$bitmapSize=6,
        [Parameter()]
        [System.Drawing.Text.TextRenderingHint]$textRenderingHint = [System.Drawing.Text.TextRenderingHint]::SystemDefault,
        [Parameter()]
        [switch]$savePicture
    )
    # 確保輸入輸出合法
    [System.IO.FileSystemInfo] $srcFile = Get-Item $srcFile -ErrorAction Stop
    $outputDir = $outputFile | Split-Path
    if ($outputDir -eq "") {
        $outputDir = "."
    }
    [System.IO.DirectoryInfo] $outputDir = Get-Item $outputDir -ErrorAction Stop # 確定輸出目錄存在順便轉型

    # 檢驗輸入的副檔名
    $extension = [System.IO.Path]::GetExtension($srcFile).ToLower()
    if (-not (@(".ttf", ".otf") -contains $extension)) {
        Write-Error "副檔名$extension 不為ttf或otf"
        return
    }

    # 建立一個FontCollection, PrivateFontCollection是在.NET Framework4.6引入，所以powershell5不支援
    $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection

    # 將我們的檔案添加至collection之中
    $fontCollection.AddFontFile($srcFile.FullName)

    # 在collection選擇該檔案
    $fontFamily = $fontCollection.Families[0]
    $font = New-Object System.Drawing.Font($fontFamily, $fontSize)

    # 取得字型支援的所有字符碼位
    # [System.Collections.Generic.List`1[System.Char]] $characterSet = New-Object System.Collections.Generic.List[char] # 這個沒辦法處理超過0xffff
    $characterSet = @()
    for ($i = $startIdx; $i -lt $endIdx; $i++) {
        if ($fontFamily.IsStyleAvailable([System.Drawing.FontStyle]::Regular)) {
            if ($i -gt 0xFFFF) {
                $character = [char]::ConvertFromUtf32($i)
            } else {
                $character = [char] $i
            }
            $bitmap = New-Object System.Drawing.Bitmap($bitmapSize, $bitmapSize)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap) # 取得graphics物件;
            $graphics.TextRenderingHint = $textRenderingHint
            # $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::SystemDefault # 這是預設

            # 置中
            $size = $graphics.MeasureString($character, $font) # 可以得字的寬高
            $x = ($bitmapSize - $size.Width) / 2 # 兩側留白/2 = 左側留白位置
            $y = ($bitmapSize - $size.Height) / 2
            $graphics.DrawString($character, $font, [System.Drawing.Brushes]::Black, $x, $y)

            $hasVisiblePixels = $false

            for ($x = 0; $x -lt $bitmap.Width; $x++) {
                for ($y = 0; $y -lt $bitmap.Height; $y++) {
                    $pixel = $bitmap.GetPixel($x, $y)
                    if ($pixel.A -gt 0) {
                        $hasVisiblePixels = $true
                        break
                    }
                }
                if ($hasVisiblePixels) {
                    break
                }
            }

            if ($hasVisiblePixels) {
                if ($savePicture.IsPresent) {
                    $bitmap.Save((Join-Path $outputDir.FullName "$i.png"), [System.Drawing.Imaging.ImageFormat]::Png) # Bmp
                }
                # $characterSet.Add($character)
                $characterSet += $character
            } else {
                Write-Verbose "empty bitmap: $i"
            }
            $graphics.Dispose()
            $bitmap.Dispose()
        }
    }

    # 輸出至檔案
    Out-File $outputFile -Encoding utf8NoBOM # 創建檔案，清空內容;
    [System.IO.FileSystemInfo] $outputFile = Get-Item $outputFile # 由於我們已經寫檔，所以檔案一定存在，所以能將其轉成FileSystemInfo物件，為了後面可以用DirectoryName
    $i = 0
    $line = ""
    $characterSet | foreach {
        $i++
        $line += $_
        if ($i -eq 10) { # 每10個一列;
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                $line | Out-File $outputFile -Append -Encoding utf8NoBOM
            } else {
                $line | Out-File $outputFile -Append -Encoding UTF8
            }
            $line = ""
            $i = 0
        }
    }

    # 補最後剩餘的資料
    if (-not ($line -eq "")) {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $line | Out-File $outputFile -Append -Encoding utf8NoBOM
        } else {
            $line | Out-File $outputFile -Append -Encoding UTF8
        }
    }

    # 釋放資源
    $fontCollection.Dispose()

    if ($VerbosePreference -eq "Continue") {
        Write-Host "Output: " -NoNewLine
        Write-Host $outputFile.FullName -ForegroundColor Green
        Start-Process "$($outputFile.DirectoryName)"
    }
}
