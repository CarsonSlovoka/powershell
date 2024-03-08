function Request-OpenAI-Help {
    Write-Host '有關於返回值，他的時間是Unix的second'
    Write-Host '- 這種方法是UTC+0的時間: [datetime]::UnixEpoch.AddSeconds(1709878845).ToString("yyyy/MM/dd HH:mm:ss")'
    Write-Host '>> 2024/03/08 06:20:45'
    Write-Host '- Get-Date -UnixTimeSeconds 1709878845'
    Write-Host '>> 2024年3月8日 下午 02:20:45'
    Write-Host 'Playground'
    Write-Host 'https://platform.openai.com/playground?assistant=<assistantID>&mode=assistant&thread=<threadID>'
}

function Request-OpenAI-OpenPlayground {
    <#
    .SYNOPSIS
       開啟playground
    .PARAMETER assistantID
        `asst_...`
    .PARAMETER threadID
        `thread_...`
    .EXAMPLE
        Request-OpenAI-OpenPlayground asst_123456789012345678901234 thread_123456789012345678901234
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$assistantID,
        [Parameter(Mandatory=$true)]
        [string]$threadID
    )
    Write-Host "https://platform.openai.com/playground?assistant=$assistantID&mode=assistant&thread=$threadID" `
        -ForegroundColor Green
    Start-Process "https://platform.openai.com/playground?assistant=$assistantID&mode=assistant&thread=$threadID"
}

function Request-OpenAI-ListThread {
    <#
    .SYNOPSIS
       列出所有的Threads訊息
    .DESCRIPTION
        請到: https://platform.openai.com/assistants 取得session key
    .PARAMETER key
        sessionKey，而非OPENAI_API_KEY

        當您想要刪除敏感資料，呼叫 Remove-PSReadlineHistory
        不過sessionKey也有時間限定，一段時間(幾個小時內)就會失效
    .PARAMETER limit
        n如果是1的時候會跑很快, 越大的n會跑越久
        1~100之間
    .EXAMPLE
        Get-OpenAI-AllThread sess-1234567890123456789012345678901234567890
    .EXAMPLE
        Get-OpenAI-AllThread sess-1234567890123456789012345678901234567890 5
    .Link
        https://platform.openai.com/assistants
        https://community.openai.com/t/list-of-threads-is-missing-from-the-api/484510/28
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$key,

        [int]$limit=5
    )

    curl "https://api.openai.com/v1/threads?&limit=$limit" `
      -H "Authorization: Bearer $key" `
      -H "OpenAI-Beta: assistants=v1"
}

function Request-OpenAI-GetThreads {
    <#
    .SYNOPSIS
       找出所指定的Thread集
    .DESCRIPTION
    .PARAMETER ids
        threads
    .PARAMETER limit
        1~100之間
    .PARAMETER order
        asc: 第一筆資料的時間最早
        desc: 第一筆資料的時間最晚
    .EXAMPLE
        Request-OpenAI-GetThreads "thread_123456789012345678901234" -order "asc"
    .EXAMPLE
        # 查詢多筆
        Request-OpenAI-GetThreads @("thread_123456789012345678901234", thread_...")
    .LINK
        https://platform.openai.com/playground?assistant=<assistantID>&mode=assistant&thread=<threadID>
    #>
    param (
        [Parameter(Mandatory=$true)]
        [array]$ids,

        [int]$limit = 20,
        [string]$order = "asc"
    )

    # $out = @()
    foreach ($threadID in $ids) {
        Write-Host "查詢此Thread: $threadID" -ForegroundColor Green # 開始前先打印出來，方便曉得已經換成另一個threadID
        # 直接打印結果就好
        curl "https://api.openai.com/v1/threads/$threadID/messages?limit=$limit&order=$order" `
            -H "Content-Type: application/json" `
            -H "Authorization: Bearer $env:OPENAI_API_KEY" `
            -H "OpenAI-Beta: assistants=v1"
        # $out += $obj # 出來的是亂碼
    }
    # return $out
}

function Request-OpenAI-GetThreadMsg {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ids
        threadID
    .PARAMETER limit
    .PARAMETER order
    .EXAMPLE
        Request-OpenAI-GetThreadMsg "thread_123456789012345678901234"
        Request-OpenAI-GetThreadMsg "thread_123456789012345678901234" -order desc
    .EXAMPLE
        # 批次查詢
        Request-OpenAI-GetThreadMsg @("thread_123456789012345678901234", thread_...") -order desc
    .LINK
    #>
    param (
        [Parameter(Mandatory=$true)]
        [array]$ids,

        [int]$limit = 20,
        [string]$order = "asc"
    )
    foreach ($threadID in $ids) {
        Write-Host "查詢此 $threadID 下的message" -ForegroundColor Green
        curl "https://api.openai.com/v1/threads/$threadID/messages?limit=$limit&order=$order" `
            -H "Content-Type: application/json" `
            -H "Authorization: Bearer $env:OPENAI_API_KEY" `
            -H "OpenAI-Beta: assistants=v1"
    }
}

function Request-OpenAI-DeleteThread {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ids
        threadID
    .EXAMPLE
        # 預設為直接刪除
        Request-OpenAI-DeleteThread "thread_123456789012345678901234"
        Request-OpenAI-DeleteThread "thread_123456789012345678901234" -Confirm

    .EXAMPLE
        # 可以查看將會刪除哪些內容
        Request-OpenAI-DeleteThread "thread_123456789012345678901234" -WhatIf
    .EXAMPLE
        # 批次查詢
        Request-OpenAI-DeleteThread @("thread_123456789012345678901234", thread_...")
    .LINK
    #>
   [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [array]$ids
    )

    foreach ($threadID in $ids) {
        Write-Host "處理: $threadID" -ForegroundColor Yellow
        if (!$WhatIfPreference) {
            # --request POST 等同 -X POST
            curl -X DELETE "https://api.openai.com/v1/threads/$threadID" `
            -H "Content-Type: application/json" `
            -H "Authorization: Bearer $env:OPENAI_API_KEY" `
            -H "OpenAI-Beta: assistants=v1" `
        } else {
          Request-OpenAI-GetThreadMsg $threadID -limit 1 -order desc
        }
    }
}

function Request-OpenAI-DeleteThread {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER id
        threadID
    .EXAMPLE
    .LINK
    #>
   [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [array]$ids
    )
}
