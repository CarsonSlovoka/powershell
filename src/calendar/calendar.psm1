<#
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Start
  The first month to display.

 .Parameter End
  The last month to display.

 .Parameter FirstDayOfWeek
  The day of the month on which the week begins.

  某些國家是習慣禮拜一、有些是用禮拜天當成第一個項目

 .Parameter HighlightDay
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .Parameter HighlightDate
  Specific days (named) to highlight. These dates are surrounded by asterisks.

 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"
   Show-Calendar (New-Object DateTime 2023,5,2) (New-Object DateTime 2023,8,8)
   Show-Calendar (New-Object DateTime 2023,5,2) (New-Object DateTime 2023,8,8) -HighlightDate "2023-08-08"

 .Example
   # Highlight a range of days.
   # 突顯1~10,22等11個日期, 以及2023-05-02
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "2023-05-02"
#>
function Show-Calendar {
    param(
        [DateTime] $start = [DateTime]::Today, # 所有的變數，前面都可以用[]來加註此變數的型別;
        [DateTime] $end = $start,
        $firstDayOfWeek,
        [int[]] $highlightDay,
        [string[]] $highlightDate = [DateTime]::Today.ToString('yyyy-MM-dd')
        )

    # Wait-Debugger # 每次更動腳本的時候，對於之前已經Import-module的腳本，要關掉再重新載入才會生效;

    ## Determine the first day of the start and end months.
    $start = New-Object DateTime $start.Year,$start.Month,1
    $end = New-Object DateTime $end.Year,$end.Month,1

    ## Convert the highlighted dates into real dates.
    [DateTime[]] $highlightDate = [DateTime[]] $highlightDate # 我們的參數定義此變數為一個string，所以用這種方式做轉換;

    ## 得到習慣使用的日期格式;
    ## Retrieve the DateTimeFormat information so that the
    ## calendar can be manipulated.
    $dateTimeFormat  = (Get-Culture).DateTimeFormat
    if($firstDayOfWeek) # 如果有定義，我們就會以定義的為主;
    {
        $dateTimeFormat.FirstDayOfWeek = $firstDayOfWeek # 以台灣為例，第一個是Sunday;
    }

    [DateTime] $currentDay = $start

    ## Process the requested months.
    while($start -le $end)
    {
        # 每一列都會完整顯示出來，不論此列的日期是不是已經經過，所以如果它已經在這個禮拜的非開頭日，我們就會回到開頭日;
        ## Return to an earlier point in the function if the first day of the month
        ## is in the middle of the week.
        while($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek)
        {
            $currentDay = $currentDay.AddDays(-1) # 以台灣為例，如果目前是禮拜三，就會退回到，前一個禮拜天的日期;
        }

        ## Prepare to store information about this date range.
        $currentWeek = New-Object PsObject
        $dayNames = @()
        $weeks = @() # 一個陣列: { {週日:30, 周一:1, 週二:2, ...週六:6}, {週日:7 周一:8, 週二:9, ...週六:13}, obj3...};

        ## Continue processing dates until the function reaches the end of the month.
        ## The function continues until the week is completed with
        ## days from the next month.
        while(($currentDay -lt $start.AddMonths(1)) -or
            ($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek)) # 如果當前月份已經全部輸出完畢，我們還是持續輸出，直到達到下一個月的FirstDayOfWeek為止;
        {
            ## Determine the day names to use to label the columns.
            $dayName = "{0:ddd}" -f $currentDay # ddd 是日期和时间格式字符串之一，它是一个自定义格式字符串，可以用于在字符串中包含日期和时间值的指定部分。在这里，它代表星期几的缩写形式;;

            <#
                下面是一些其他常见的日期和时间格式字符串：
                yyyy：年份，如 2022
                MM：月份，如 09
                ddd: 星期幾
                dd：日，如 25
                HH：小时（24 小时制），如 16
                mm：分钟，如 35
                ss：秒，如 45;
            #>
            if($dayNames -notContains $dayName)
            {
                $dayNames += $dayName
            }

            ## Pad the day number for display, highlighting if necessary.
            $displayDay = " {0,2} " -f $currentDay.Day # Day

            # 如果需要突顯，我們會在前面補上*;
            ## Determine whether to highlight a specific date.
            if($highlightDate)
            {
                $compareDate = New-Object DateTime $currentDay.Year,
                    $currentDay.Month,$currentDay.Day
                if($highlightDate -contains $compareDate)
                {
                    $displayDay = "*" + ("{0,2}" -f $currentDay.Day) + "*"
                }
            }

            ## Otherwise, highlight as part of a date range.
            if($highlightDay -and ($highlightDay[0] -eq $currentDay.Day)) # 因為日期有順序性，所以我們每次都只比較第一個日期，如果吻合，我們會更新第一個日期，讓接下來的比較符合我們的預期;
            {
                $displayDay = "[" + ("{0,2}" -f $currentDay.Day) + "]"

                <#
                 $a,$b = 33, 55
                 $a # 33
                 $b 55

                 $a,$b = 33
                 $a = 33
                 $b # 沒有東西，因為賦值的時候沒有東西給他

                 $a = 1..10
                 $null,$a = $a # 相當於把$a的第一個元素拿掉, $null是一個保留變數，任何東西附值給他都會無效，再次打印$null還是不會看到東西

                 $a = 1..10
                 $my1, $my2 = $a
                 $my1 # 1
                 $my2 # 2~10;
                #>
                $null,$highlightDay = $highlightDay # 每次都將頭元素拿掉;
            }

            ## Add the day of the week and the day of the month as note properties.
            $currentWeek | Add-Member NoteProperty $dayName $displayDay # 相當於設定$currentWeek為一個PSCustomObject變數，它有一個變數名稱為$dayName，它的數值為$displayDay，例如: 週日: 30;

            ## Move to the next day of the month. # 下一天;
            $currentDay = $currentDay.AddDays(1)

            # 當如果已經到達了下一個FirstDayOfWeek，那麼就表示這一個星期的資料都已經得到，可以保存;
            ## If the function reaches the next week, store the current week
            ## in the week list and continue.
            if($currentDay.DayOfWeek -eq $dateTimeFormat.FirstDayOfWeek)
            {
                $weeks += $currentWeek
                $currentWeek = New-Object PsObject # 清空變數;
            }
        }

        ## Format the weeks as a table.
        <#
            將
            item1
            item2
            ...
            itemN

            改成
            item1|i2|..|itemN;
        #>
        $calendar = $weeks | Format-Table $dayNames -AutoSize | Out-String # $weeks { {週日:30, 周一:1, 週二:2, ...週六:6}, {週日:7 周一:8, 週二:9, ...週六:13}, obj3...}。當您用Format-List，或者直接打印就是這個樣子。然而使用Format-Table，就會是橫向的長法: item1|item2|...|itemN，這個看法就與日曆一樣了;

        ## Add a centered header.
        $width = ($calendar.Split("`n") | Measure-Object -Maximum Length).Maximum # 取得最長的長度列;

        # Wait-Debugger

        $header = "{0:MMMM yyyy}" -f $start # 5月 2023;
        $padding = " " * (($width - $header.Length) / 2)
        # $displayCalendar = " `n" + $padding + $header + "`n " + $calendar # 空一行, header要置中, 日曆資料;
        $displayCalendar = [String]::Format("`n{0}{1}`n{2}", $padding, $header, $calendar) # 同上;

        $displayCalendar.TrimEnd() # 把多餘空行拿掉;

        ## Move to the next month.
        $start = $start.AddMonths(1)
    }
}
