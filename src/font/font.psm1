function Save-FontChars {
    <#
    .Synopsis
        讀取字型檔案的每一個碼位，輸出其文字至指定的檔案(每10個字一列)，也可將該字的png保存起來
    .Description
        javascript: escape("風") 可以得知此碼位是: '%u98A8'
    .Parameter fontPath
        字型檔案路徑
    .Parameter outputFile
        輸出的檔案路徑，每10個字一列寫到檔案之中
    .Parameter autoIdx
        當autoIdx開啟時，會使用GlyphMap的資料為主，並且忽略startIdx與endIdx
    .Parameter startIdx
        開始的碼位
        你可以指定到GlyphMap沒有的碼位，此時呈現的圖片，會是使用其他系統字型替代出來的樣子，並非該字型檔本身所提供的glyph
    .Parameter endIdx
        結束的碼位
        你可以指定到GlyphMap沒有的碼位，此時呈現的圖片，會是使用其他系統字型替代出來的樣子，並非該字型檔本身所提供的glyph
        預設值為0x11FFFF，正常來說不應該超過此範圍
    .Parameter fontSize
        判斷字的成像是否有內容用
        如果設定太小，畫出來會只有一個點
    .Parameter bitmapSize
        判斷字的成像是否有內容用
    .Parameter textRenderingHint
        如果要印出比較漂亮的字，要用 [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

        ClearType: 這種技術通常是把小字的圖放鑲嵌進去字型檔，使得在小字的呈現上效果會比較好。對於低解析度的顯示器會比較好看
    .Parameter savePicture
        如果設定會連帶畫出來的圖片一起保存，保存的位子和 outputFile 相同的資料夾
    .Example
        Save-FontChars src.ttf out.txt -autoIdx
    .Example
        Save-FontChars "C:\xxx\src.ttf" ".\temp\out.txt" -autoIdx
    .Example
        Save-FontChars "C:\xxx\src.ttf" "C:\ooo\out.ttf" -endIdx 256 -fontSize 48 -bitmapSize 72 -textRenderingHint AntiAliasGridFit -savePicture -Verbose
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
        Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 48 -bitmapSize 72 -savePicture
        Save-FontChars src.ttf out.txt -startIdx 0x98a8 -endIdx 0x98aa -fontSize 48 -bitmapSize 72 -savePicture -textRenderingHint AntiAliasGridFit
        Save-FontChars src.ttf out.txt -endIdx 200 -fontSize 48 -bitmapSize 72 -savePicture -textRenderingHint AntiAliasGridFit -Verbose
    .Example
        Save-FontChars (Join-Path $env:SystemRoot fonts/Arial.ttf) out.txt -startIdx 0x3579 -endIdx 0x3590 -fontSize 48 -bitmapSize 72 -savePicture
    #>
    param (
        [Parameter(Mandatory)]
        [string]$fontPath,
        [Parameter(Mandatory)]
        [string]$outputFile,
        [Parameter()]
        [switch]$autoIdx,
        [Parameter()]
        [int]$startIdx = 0,
        [Parameter()]
        [int]$endIdx = 0x11FFFF,
        [Parameter()]
        [int]$fontSize=3,
        [Parameter()]
        [int]$bitmapSize=6,
        [Parameter()]
        [ValidateSet( # ValidateSet只能用常數，不能直接放[System.Drawing.Text.TextRenderingHint]::SystemDefault
            "SystemDefault",
            "SingleBitPerPixel",
            "SingleBitPerPixelGridFit",
            "AntiAlias",
            "AntiAliasGridFit",
            "ClearTypeGridFit"
        )]
        [string]$textRenderingHint = "SystemDefault",

        [Parameter()]
        [switch]$savePicture
    )

    $textRenderingHintMap = @{
        SystemDefault = [System.Drawing.Text.TextRenderingHint]::SystemDefault
        SingleBitPerPixel = [System.Drawing.Text.TextRenderingHint]::SingleBitPerPixel
        SingleBitPerPixelGridFit = [System.Drawing.Text.TextRenderingHint]::SingleBitPerPixelGridFit
        AntiAlias = [System.Drawing.Text.TextRenderingHint]::AntiAlias
        AntiAliasGridFit= [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        ClearTypeGridFit = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    }

    [System.Drawing.Text.TextRenderingHint]$textRenderingHint = $textRenderingHintMap[$textRenderingHint]

    # 確保輸入輸出合法
    [System.IO.FileSystemInfo] $fontPath = Get-Item $fontPath -ErrorAction Stop
    $outputDir = $outputFile | Split-Path
    if ($outputDir -eq "") {
        $outputDir = "."
    }
    [System.IO.DirectoryInfo] $outputDir = Get-Item $outputDir -ErrorAction Stop # 確定輸出目錄存在順便轉型

    # 檢驗輸入的副檔名
    $extension = [System.IO.Path]::GetExtension($fontPath).ToLower()
    if (-not (@(".ttf", ".otf") -contains $extension)) {
        Write-Error "副檔名$extension 不為ttf或otf"
        return
    }

    # 建立一個FontCollection, PrivateFontCollection是在.NET Framework4.6引入，所以powershell5不支援
    $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection

    # 將我們的檔案添加至collection之中
    $fontCollection.AddFontFile($fontPath.FullName)

    # 在collection選擇該檔案
    $fontFamily = $fontCollection.Families[0]
    $font = New-Object System.Drawing.Font($fontFamily, $fontSize)

    function get-CharacterSet($unicodeIdx) {
        $char = ""
        if ($fontFamily.IsStyleAvailable([System.Drawing.FontStyle]::Regular)) {
            if ($unicodeIdx -gt 0xFFFF) {
                $character = [char]::ConvertFromUtf32($unicodeIdx) # 這個也不能處理超過0x10FFFF以及如果是surrogate pair( U+D800 到 U+DFFF)也會錯誤
            } else {
                $character = [char] $unicodeIdx
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
                    $hex = ("{0:X}" -f $unicodeIdx).PadLeft(4, "0")
                    $bitmap.Save((Join-Path $outputDir.FullName "$hex.png"), [System.Drawing.Imaging.ImageFormat]::Png) # Bmp
                }
                $char = $character
            } else {
                Write-Verbose "empty bitmap: $unicodeIdx"
            }
            $graphics.Dispose()
            $bitmap.Dispose()
        }
        return $char
    }

    # 取得字型支援的所有字符碼位
    # [System.Collections.Generic.List`1[System.Char]] $characterSet = New-Object System.Collections.Generic.List[char] # 這個沒辦法處理超過0xffff
    $characterSet = @()
    if ($autoIdx) {
        Add-Type -AssemblyName PresentationCore
        $glyphTypeface = New-Object -TypeName Windows.Media.GlyphTypeface -ArgumentList $fontPath.FullName # 可以給非絕對路徑，只是我們前面已經把$fontPath轉成FileSystemInfo，所以要再轉成字串才能用
        $glyphTypeface.CharacterToGlyphMap | foreach {
            # CharacterToGlyphMap是一個Array每一個元素為一個Key, Value的組合，其中Key指的是unicode的碼位, Value表示glyphIdx
            $ch = get-CharacterSet $_.Key
            if (!($ch -eq "")) {
                $characterSet += $ch
            }
        }
    } else {
        for ($i = $startIdx; $i -lt $endIdx; $i++) {
            $ch = get-CharacterSet $i
            if (!($ch -eq "")) {
                $characterSet += $ch
            }
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

function Export-GlyphToExcel {
    <#
    .Description
        把字畫到excel之中

        如果遇到錯誤: Microsoft Excel 無法貼上資料。 請把所有EXCEL關掉，之後請手動打開excel再關閉。
    .Parameter fontPath
        C:\...\my.ttf
    .Parameter outputPath
        輸出的xlsx路徑
    .Parameter chars
        一個二維陣列，內容的型別可以是{string, int}例如:
        ```
        $chars = @(
            @('中',[char]::ConvertFromUtf32(0x3579)),
            @('A', '0x41', '65', '您', '好')
        )
        ```
    .Parameter bitmapSize
        文件右鍵所看到的檔案尺寸大小
    .Parameter label
        如果使用此屬性，那麼會將該字的碼位標示於圖形的下方
    .Example
        $chars = @(
            @('中',[char]::ConvertFromUtf32(0x597D)),
            @('A', 0x41, 65, '您', '好', "多字", "Good")
        )
        # 可以多個字，但是圖像大小和字的大小要自己抓，不然會畫不完全
        Export-GlyphToExcel (Join-Path $env:SystemRoot fonts/Arial.ttf) "tempOutput.xlsx" $chars -fontSize 12
        Export-GlyphToExcel (Join-Path $env:SystemRoot fonts/Arial.ttf) "tempOutput.xlsx" $chars -fontSize 12 -label
    .Example
        # 如果只有一列，可以考慮多給一個空白列，以保持是二維陣列的形式，讓輸出格式能符合預期
        $chars = @(
            @("A", 65, '好'),
            @()
        )
        # 微軟正黑體
        Export-GlyphToExcel (Join-Path $env:SystemRoot fonts/msjhl.ttc) "tempOutput.xlsx" $chars
    #>
    param (
        [Parameter(Mandatory)]
        [string]$fontPath,
        [Parameter(Mandatory)]
        [string]$outputPath,
        [Parameter(Mandatory)]
        [Object[][]]$chars,
        [Parameter()]
        [int]$bitmapSize=72,
        [Parameter()]
        [int]$fontSize=48,
        [Parameter()]
        [switch]$label
    )

    $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
    $fontCollection.AddFontFile($fontPath)

    # 在collection選擇該檔案
    $fontFamily = $fontCollection.Families[0]
    $font = New-Object System.Drawing.Font($fontFamily, $fontSize)

    # 建立 Excel 物件
    $excel = New-Object -ComObject Excel.Application
    # $excel.Visible = $false  # 讓excel程序不可見
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    # 統一將所有儲存格調整成bitmap的大小
    $worksheet.Cells.EntireRow.RowHeight = $bitmapSize / 1.333
    $worksheet.Cells.EntireColumn.ColumnWidth = $bitmapSize * 0.11638

    ## 引入相關的名稱空間, 放在for中也可以，只要引入了即便離開了{}也能作用
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") # $worksheet.Paste會需要用到
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $needSave = $false
    for ($row=0; $row -lt $chars.Length; $row++) {
        for ($col=0; $col -lt $chars[$row].Length; $col++) {
            $char = $chars[$row][$col]
            # 繪製字型圖形
            ## 建立bitmap
            $bitmap = New-Object System.Drawing.Bitmap($bitmapSize, $bitmapSize)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap) # 取得graphics物件;
            # $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::SystemDefault # 這是預設
            $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

            $character = ""
            if ($char -is [int]) {
                # $character = [char]::ConvertFromUtf32(0x1F44D)  # "👍"
                $character = [char]::ConvertFromUtf32($char)
            } else {
                if (!($char -is [string])) {
                    Write-Host "invalid char" -NoNewLine
                    Write-Host $char -ForegroundColor Red
                    continue
                }
                $character = $char
            }
            $needSave = $true

            ## 置中
            $size = $graphics.MeasureString($character, $font) # 可以得到字的寬高
            $x = ($bitmapSize - $size.Width) / 2 # 兩側留白/2 = 左側留白位置
            $y = ($bitmapSize - $size.Height) / 2
            $graphics.DrawString($character, $font, [System.Drawing.Brushes]::Black, $x, $y)

            # 轉成png，不然有些裝置對於bitmap會把背景變成灰色
            $memoryStream = New-Object System.IO.MemoryStream
            $bitmap.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)

            # 將 MemoryStream 轉換為 DataObject 才可以讓SetDataObject使用
            $dataObject = New-Object System.Windows.Forms.DataObject
            $dataObject.SetData("PNG", $memoryStream)

            # 將 Bitmap 插入 Excel
            # $excelRange = $worksheet.Range("A1")
            $cell = ""
            if ($label) {
                $realRow = 2 * $row # 每一筆資料視為兩列，其中一個資料紀錄unicode的碼位
                $unicode = @()
                for ($i=0; $i -lt $character.Length; $i++) {
                    # $codePoint = [char]::ConvertToUtf32($character[$i], 0) # A valid high surrogate character is between 0xd800 and 0xdbff 代理對碼位會有問題
                    $utf32bytes = [System.Text.Encoding]::UTF32.GetBytes($character[$i])
                    $codePoint = [System.BitConverter]::ToUint32($utf32bytes)
                    $codePoint = ("{0:X}" -f $codePoint).PadLeft(4, "0") # 轉16進位，並填充0
                    $unicode += "0x$codePoint"
                }
                $cell = $worksheet.Cells.Item($realRow+1, $col+1)
                $worksheet.Cells.Item($realRow+2, $col+1).Value2 = $unicode -join " "
            } else {
                $cell = $worksheet.Cells.Item($row+1, $col+1) # excel的下標從1開始
            }

            # 調整儲存格大小
            # $cellRange.RowHeight = $bitmapSize / 1.333
            # $cellRange.ColumnWidth = $bitmapSize * 0.11638
            # $excelRange.Select() | Out-Null
            $cell.Select() | Out-Null

            # [System.Windows.Forms.Clipboard]::SetDataObject($bitmap, $true) # bitmap存到excel會有灰色的背景色，所以要轉成png
            [System.Windows.Forms.Clipboard]::SetDataObject($dataObject, $true)
            $worksheet.Paste($cell) # Paste Range or cell both ok. # https://learn.microsoft.com/en-us/office/vba/api/excel.worksheet.paste

            # 釋放資源
            $graphics.Dispose()
            $bitmap.Dispose()
            $memoryStream.Dispose()
        }

        # 調整標籤的高度 (圖片高度自動調整無效，所以不調)
        if ($label) {
            $range = $worksheet.Rows.Item($row*2+2) # 標籤在第二列
            $range.EntireRow.AutoFit() | Out-Null
        }
    }

    # 自動調整所有寬度
    if ($label) {
        $usedRange = $worksheet.UsedRange
        $usedRange.EntireColumn.AutoFit() | Out-Null
    }

    if ($needSave) {
        # 存檔, 取得絕對路徑
        [System.Windows.Forms.Clipboard]::Clear()
        Out-File $outputPath -Encoding utf8NoBOM # 創建空檔案
        $absOutputPath = Convert-Path -Path $outputPath # Convert-Path需要檔案已經存在
        Remove-Item $absOutputPath # 刪除，避免被對話框詢問是否要被覆蓋

        Write-Host "output:" -NoNewLine
        Write-Host $absOutputPath -ForegroundColor Yellow
        $workbook.SaveAs($absOutputPath) # 會被詢問是否要覆蓋; https://learn.microsoft.com/en-us/office/vba/api/excel.workbook.saveas
        # https://learn.microsoft.com/en-us/office/vba/api/excel.xlsaveconflictresolution # 2: 強制 3: 拒絕 1: 對話框詢問;
    }

    $workbook.Close($true)
    $excel.Quit()

    # 釋放 COM 物件
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
