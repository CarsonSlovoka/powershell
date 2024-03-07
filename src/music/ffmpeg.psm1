function New-Music {
    <#
    .SYNOPSIS
       剪輯音樂
    .DESCRIPTION
       使用ffmpeg來剪輯音樂
    .PARAMETER inputPath
       > 請注意不要用 .PARAMETER input 這好像是保留字，會得不到變數
       來源音訊檔案路徑

       可以是絕對路徑或者相對路徑
       ✅ ./input.m4a
       ❌ input.m4a # 這在Get-Item會報錯

    .PARAMETER starTime
       從哪裡開始剪輯 hh:mm:dd
    .PARAMETER inputPath
       剪輯到哪裡結束 hh:mm:dd
    .PARAMETER output
       如果省略，同input的位置，後面會加上_output來區別
       > 注意，附檔名必須和input一模一樣，不能跨，例如mp3轉m4a, 只能是mp3轉mp3或者mp4轉mp4
    .EXAMPLE
        New-Music "./input.mp3" "00:00:24" "00:00:59"
        cutMusic "./input.mp3" "00:00:24" "00:00:59"
    .EXAMPLE
        New-Music "C:\...\input.mp3" "00:00:24" "00:00:59" -output output.mp3
    .Link
        # ffmpeg下載: ffmpeg-master-latest-win64-gpl.zip
        # 最後一個版本
        - https://github.com/BtbN/FFmpeg-Builds/releases
        # 指定版本
        - https://github.com/BtbN/FFmpeg-Builds/releases/tag/autobuild-2024-03-06-16-45
    #>
    [alias('cutMusic')]
    param (
        [Parameter(Mandatory=$true)]
        [string]$inputPath,
        [Parameter(Mandatory=$true)]
        [string]$startTime,
        [Parameter(Mandatory=$true)]
        [string]$endTime,

        [string]$output
    )

    $inputPath = (Get-Item -Path $inputPath).FullName # 取得絕對路徑，不然只有檔名的時候Get-Item會有問題
    $ext = [System.IO.Path]::GetExtension($inputPath) # 已經包含.
    $baseNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)

    if ($output -eq "") {
        $outputDir = (Get-Item -Path $inputPath).Directory.FullName
        $output = Join-Path $outputDir ("{0}_output{1}" -f $baseNameWithoutExt, $ext)
    }

    Write-Host $inputPath -ForegroundColor Green
    Write-Host $output -ForegroundColor Green
    if ((Read-Host -Prompt "是否要繼續(y/n)")  -eq 'y') {
        ffmpeg -i $inputPath `
            -ss $startTime `
            -to $endTime `
            -c:a copy $output
    }
}
