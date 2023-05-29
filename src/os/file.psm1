$ENCODING = ""
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $ENCODING = "utf8NoBOM"
} else {
    $ENCODING = "utf8"
}


<#
.Description
    在工作路徑中，只要檔案名稱不存在於lst之中，就會刪除。
.Parameter srcLst
    清單檔案的路徑

    其中該檔案的內容，都只放檔案名稱，例如

    ```
    1.png
    2.png
    3.txt
    ```

    以上符合這些檔名的項目將保留，其他的都會刪除
.Parameter filter
    *.*
    *.txt
    *....
.Example
    # 刪除img目錄中，其檔案名稱非存在於src.lst之中的檔案
    Remove-NotInListFiles src.lst -workDir img -WhatIf
    # 有包含子目錄
    Remove-NotInListFiles src.lst -workDir img -recurse -WhatIf
.Example
    # 挑選img目錄中所有xml檔案，若其檔案名稱非存在於src.lst之中就會刪除
    Remove-NotInListFiles src.lst -workDir img -filter *.xml -WhatIf
    # 有包含子目錄
    Remove-NotInListFiles src.lst -workDir img -filter *.xml -recurse -WhatIf
#>
function Remove-NotInListFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$srcLst,
        [Parameter(Mandatory)]
        [string]$workDir,
        [Parameter()]
        [switch]$recurse,
        [Parameter()]
        [string]$filter = "*.*"
    )
    # 從src.lst中查詢哪些檔案名稱需被留下;
    $srcContent = Get-Content $srcLst -Encoding $ENCODING
    if ($srcContent -eq $null) {
        Write-Error "srcLst.content is null."
        return
    }
    [System.Array] $keepFiles = $srcContent.Split("`n")

    # 從工作路徑中挑選出符合篩選條件的檔案(這些檔案之後若不在保留清單中就會被刪除);
    [System.Object[]]$allFiles = @()
    if ($recurse) {
        $allFiles = Get-ChildItem -Path $workDir -Filter $filter -Recurse -ErrorAction Stop # 加上recurse，他會把所有{DirectoryInfo, FileSystemInfo}都列出來，例如a目錄有3個檔案, 當前目錄有5個檔案，那麼Length=1(a目錄)+3+5=9;
    } else {
        $allFiles = Get-ChildItem -Path $workDir -Filter $filter -ErrorAction Stop
        # $allFiles = $allFiles | Where-Object { -not $_.GetType().FullName.StartsWith("System.IO.DirectoryInfo") } # 除果非recursive，我們就不處理目錄 # 不需要特別排除;
    }

    if ($allFiles -eq $null) {
        Write-Error "[NotFoundAnyError] 工作目錄: $workDir 中沒有找到相符合的檔案. 即:刪除的清單為空;"
        return
    }

    # $src | foreach {} 這種方式在裡面用continue會整個跳掉，最好用foreach( in )的方式來處理;
    foreach($_ in $allFiles) {
        # Wait-Debugger

        if ($_.PSIsContainer) {
            continue
        }

        if ($keepFiles -notContains $_.Name) { # notContains只有Array可以用，所以不能反過來寫;
            if (!$WhatIfPreference) {
                $_.Delete()
            } else {
                Write-Host "Will Delete " -NoNewLine
                Write-Host "$($_.FullName)" -ForegroundColor Yellow
            }
        }
    }
}

function Rename-WithSerialNumber {
    <#
    .Description
        從工作目錄中挑選出指定副檔名的檔案，將這些檔案依照流水號的方式重新命名，

        完成之後可以在輸出檔案中查看到原始的檔案名稱與流水號檔名的配對，已得知原始的檔案名稱匹配與目前哪一個檔案
    .Parameter filter
        例如: *.png
        此為Get-ChildItem -Filter會用到的項目
    .Parameter outputFile
        保存舊檔名與新檔名的配對
        csv format
    .Outputs
        @{
           [PSObject]Datas = {
             Old = $f.FullName
             New = $newName
            }
           Err = $null
        }
    .Example
        $o = Rename-WithSerialNumber -wkDir img -filter *.png -WhatIf
        $o.Datas
    .Example
        $o = Rename-WithSerialNumber -wkDir img -filter *.png -outputFile "result.csv" -recurse
    .Example
        $o = Rename-WithSerialNumber img *.png
        $o.Datas
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$wkDir,
        [Parameter(Mandatory)]
        [string]$filter,
        [Parameter()]
        [string]$outputFile = "",
        [Parameter()]
        [switch]$recurse
    )

    $o = @{
       Datas = @() # System.Array
       Err = $null
    }

    [System.Object[]]$allFiles = @()
    try {
        if ($recurse) {
            $allFiles = Get-ChildItem -Path $wkDir -Filter $filter -Recurse -ErrorAction Stop
        } else {
            $allFiles = Get-ChildItem -Path $wkDir -Filter $filter -ErrorAction Stop
        }

        # $allFiles = $allFiles | Sort-Object -Property Name # 排序，使的測試的輸出結果可以穩定; 沒用在powershell5和7的排法會有不同;
        $allFiles = $allFiles | Sort-Object -Property CreationTime
    } catch {
        $o.Err = $_.Exception.Message
        return $o
    }

    for ($i = 0; $i -lt $allFiles.Length; $i++) {
        [System.IO.FileSystemInfo]$f = $allFiles[$i]
        if ($f.PSIsContainer) { # directory
            continue
        }

        [string]$basename = ($i + 1)

        # 防止新檔名已經存在的狀況發生;
        while(1) {
            $newName = "{0}{1}" -f $basename, $f.Extension
            if (Test-Path (Join-Path $f.Directory.FullName $newName)) {
                $basename += "_copy"
            } else {
                break
            }
        }

        $o.Datas += [PSObject]@{
            Old = $f.FullName
            New = $newName
        }

        Rename-Item $f.FullName $newName
    }

    if (!$WhatIfPreference -and !($outputFile -eq "")) {
        try {
            Out-File $outputFile -Encoding $ENCODING -ErrorAction Stop # 創建檔案，清空內容;
        } catch {
            $o.Err = $_.Exception.Message
            return $o
        }

        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $o.Datas | ConvertTo-Csv -NoTypeInformation | Out-File $outputFile -Encoding $ENCODING
        } else {
            $o.Datas | Out-File $outputFile -Encoding $ENCODING # 這種輸出方式其實有問題，因為$o.Datas是直接輸出，類似在console視窗所看到的樣子，所以如果太長，文字會用...來取代。;
        }
    }

    return $o
}
