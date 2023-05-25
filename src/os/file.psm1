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
    $srcContent = Get-Content $srcLst -Encoding UTF8
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
