function Show-DateTime {
    <#
    .Synopsis
        將日期和時間顯示在一個dialog之中
    .Description
        透過Get-Date來取得當前的日期時間，並利用Form來呈現
    .Parameter title
        Dialog的標題內容
    .Example
        Show-DateTime
        ShowDT
    .Example
        Show-DateTime "現在時間"
        ShowDT -Title "現在時間"
    #>
    [alias('ShowDT')]
    [CmdletBinding()]
    param (
        [Parameter()]
        [alias('Title')][string]$titleText="Current Time"
    )

    # https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms?view=windowsdesktop-7.0
    Add-Type -AssemblyName System.Windows.Forms

    $form =  [System.Windows.Forms.Form]::new()
    $form.Text = $titleText
    $form.Size = [System.Drawing.Size]::new(300, 100)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

    $label = [System.Windows.Forms.Label]::new()
    $label.Text = (Get-Date).ToString("hh:mm:ss tt")
    $label.AutoSize = $true
    $label.Location = [System.Drawing.Point]::new(10, 20)

    $form.Controls.Add($label)

    $timer = [System.Windows.Forms.Timer]::new()

    $form.add_FormClosing({
        $timer.Stop()
    })

    $timer.Interval = 1000
    $timer.Add_Tick({
        $label.Text = (Get-Date).ToString("hh:mm:ss tt")
    })

    $timer.Start()
    $form.ShowDialog() | Out-Null
}

<# 避免不相關的函數影響到測試覆蓋率
# ($a,$b | Measure-Object -Minimum).Minimum # 也可以辦到;
function min {
    param (
        [Parameter(Mandatory)][int]$a,
        [Parameter(Mandatory)][int]$b
    )
    if ($b -lt $a) {
        return $b
    }
    return $a
}
#>


function Set-Countdown {
    <#
    .Synopsis
        如果您對於時間掌握有特殊的需求，例如主持會議希望在特定時間內能講完，可以使用此倒數計時器來幫您
    .Description
        以秒數為單位，當時間到會自動關閉計時視窗
    .Parameter sec
        倒數的秒數
    .Parameter opacity
        form的透明度，1為完全不透明, 0為透明
    .Parameter dangerCriteria
        second
        在此秒數以下，將會強制做以下調整:
        - form.opacity: 1,
        - label.ForeColor = Red
        - label.Style = Bold
        來提醒使用者時間快結束了！
    .Example
        Set-Countdown 10
        Set-Countdown 10 -topMost
    .Example
        ```
        # 直接輸入秒數
        Set-Countdown 320 # 5 min 21 min
        ```
    .Example
        ``` 利用()來計算秒數
        Set-Countdown (60*5+21)
        ```
    .Example
        ```
        # 倒數計時18秒，透明度為0.4，當低於10秒時字會變Bold, Color:Red, opacity:1
        Set-Countdown 18 -opacity 0.4 -dangerCriteria 10
        Set-Countdown 18 -opacity 0.4 -dangerCriteria 10 -topMost
        ```
    #>
    param (
        [Parameter(Mandatory)]
        [int]$sec,
        [Parameter()]
        [ValidateScript({
            if (($_ -lt 0) -or ($_ -gt 1)) {
                throw "Invalid Opacity value. should be 0~1."
            }
            return $true
        })][float]$opacity = 1.0,
        [Parameter()]
        [int]$dangerCriteria = 0,
        [Parameter()]
        [switch]$topMost
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form =  [System.Windows.Forms.Form]::new()
    $form.Text = $titleText
    $form.Size = [System.Drawing.Size]::new(300, 200)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable # 可隨意調整大小 # 大小固定 FixedSingle;
    $form.Opacity = $opacity
    if ($topMost) {
        $form.TopMost = $true
    }

    $label = [System.Windows.Forms.Label]::new()

    # $timeSpan = New-Object TimeSpan 0,0,0,$sec
    # $timeString = "{0:hh\:mm\:ss tt}" -f ([DateTime]::Today + $timeSpan) # 05:01:01 am

    $sizeChangedEventHandler = {
        # 改變字體大小
        $fontSize = (($form.ClientSize.Width / 2),($form.ClientSize.Height / 2) | Measure-Object -Minimum).Minimum
        # $label.Font.Size = $fontSize # 'Size' is a ReadOnly property.
        $label.Font = [System.Drawing.Font]::new($label.Font.FontFamily, $fontSize, $label.Font.Style)
        # 置中
        $label.Location = [System.Drawing.Point]::new(($form.ClientSize.Width - $label.Width) / 2, ($form.ClientSize.Height - $label.Height) / 2)
    }
    $form.add_SizeChanged($sizeChangedEventHandler)

    $label.Text = $sec
    $label.AutoSize = $true # 預設為false,此時如果字體太大，超出範圍的內容將會被截掉；為true的時候，依據需要佔用多少矩形面積會自己計算。;
    # $fontSize = min ($form.ClientSize.Width / 2) ($form.ClientSize.Height / 2)
    $fontSize = (($form.ClientSize.Width / 2),($form.ClientSize.Height / 2) | Measure-Object -Minimum).Minimum
    $label.Font = [System.Drawing.Font]::new("Arial", $fontSize,
        [System.Drawing.FontStyle]::Regular # https://learn.microsoft.com/en-us/dotnet/api/system.drawing.fontstyle?view=windowsdesktop-7.0
    )
    # $label.Location = [System.Drawing.Point]::new(($form.ClientSize.Width - $label.Width) / 2, ($form.ClientSize.Height - $label.Height) / 2) # 注意，$label.Width用AutoSize所以要$form.Controls.Add之後才能得知;
    $form.Controls.Add($label)
    $label.Location = [System.Drawing.Point]::new(($form.ClientSize.Width - $label.Width) / 2, ($form.ClientSize.Height - $label.Height) / 2) # 置中，注意它的位置需要先添加到form才能得知;

    $timer = [System.Windows.Forms.Timer]::new()

    $form.add_FormClosing({
        $timer.Stop()
    })

    $timer.Interval = 1000
    $timer.Add_Tick({
        # $sec = $sec-- # 無效，變數沒辦法傳到下一個Tick;
        $curVal = [int]::Parse($label.Text)
        $curSec = $curVal - 1 # 以當前的Text來計算;
        if ($curSec -eq 0) {
            # $label.Text = (Get-Date).ToString("hh:mm:ss tt")
            $timer.Stop() # 重複調用沒關係;
            $form.Close() # 直接退出;
            return
        }
        if ( (!($label.Font.Style -eq [System.Drawing.FontStyle]::Bold)) -and # 如果已經是粗體，表示已經調整過，不需要再調整
            ($curSec -lt $dangerCriteria)) {
            # 以下只需做一次，用Style來判別是否需要執行;
            $form.Opacity = 1
            $label.Font = [System.Drawing.Font]::new($label.Font.FontFamily, $label.Font.Size, [System.Drawing.FontStyle]::Bold)
            $label.ForeColor = [System.Drawing.Color]::Red
            # Write-Host "do one" # 有作用
            # Write-Output/echo "do one" # form作用下，使用這些語法"沒辦法"順利把命令傳送到終端機;
        }
        $label.Text = "$(($curSec,0 | Measure-Object -Maximum).Maximum)"
        if (!("$curVal".Length -eq "$curSec".Length)) {
            # 長度如果發生變化，則位置重新計算，以維持居中;
            $label.Location = [System.Drawing.Point]::new(($form.ClientSize.Width - $label.Width) / 2, ($form.ClientSize.Height - $label.Height) / 2)
        }
    })

    $timer.Start()
    $form.ShowDialog() | Out-Null
    return $null
}
