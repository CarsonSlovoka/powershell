function Request-OpenAI-CreateMessage {
    <#
    .SYNOPSIS
        在某一個thread建立要輸出的訊息
    .DESCRIPTION
        此功能只是建立訊息，要實際執行，還需要透過run才會真的運行
    .PARAMETER threadID
    .EXAMPLE
        $body = @{
            role = 'user' # 目前只能是user
            content = ''
            file_ids = @('', '') # 可選項，如果要給它，要先上傳檔案上去
            metadata = @{
                time = Get-Date
                author = 'Carson'
            }
        }
        Request-OpenAI-CreateMessage thread_... $body
    .LINK
        https://platform.openai.com/docs/api-reference/messages/getMessage
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [hashtable]$body
    )

    curl -X POST "https://api.openai.com/v1/threads/$threadID/messages" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1" `
      -d ($body | ConvertTo-Json)
}

function Request-OpenAI-GetThreadMsg {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER threadID
    .PARAMETER messageID
    .EXAMPLE
        Request-OpenAI-GetThreadMsg thread_... msg_...
    .LINK
        https://platform.openai.com/docs/api-reference/messages/getMessage
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$messageID
    )
    curl -X POST "https://api.openai.com/v1/threads/$threadID/messages/$messageID" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1"
}

function Request-OpenAI-ListThreadMsg {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ids
        threadID
    .PARAMETER limit
    .PARAMETER order
    .EXAMPLE
        Request-OpenAI-ListThreadMsg "thread_123456789012345678901234"
        Request-OpenAI-ListThreadMsg "thread_123456789012345678901234" -order desc
    .EXAMPLE
        # 批次查詢
        Request-OpenAI-ListThreadMsg @("thread_123456789012345678901234", thread_...") -order desc
    .LINK
        https://platform.openai.com/docs/api-reference/messages/listMessages
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

function Request-OpenAI-ModifyMessage {
    <#
    .SYNOPSIS
        修改已經發送出去的訊息
        注意，只能修改metadata的內容！
    .DESCRIPTION
        它只能修改，以key為主，而不是Set
        例如原本的資料已經有author
        如果新的meta的內容只有`time = Get-Date`，
        那麼它就只會把原本的meta添加或者修改(看原本有沒有)這個key的值，其他的內容不動
    .PARAMETER threadID
    .PARAMETER messageID
    .PARAMETER metadata
        key長度最多為64
        value長度為512
    .EXAMPLE
        Request-OpenAI-ModifyMessage thread_... msg_...
    .EXAMPLE
        # 自定義meta訊息
        $myMeta = @{
            modified = "true"
            time = Get-Date
            author = 'Carson'
        }
        Request-OpenAI-ModifyMessage thread_... msg_... $myMeta
    .LINK
        https://platform.openai.com/docs/api-reference/messages/modifyMessage
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$messageID,

        [hashtable]$metadata = @{
            modified = "true"
            time = Get-Date
        }
    )

    <#
    $uri = "https://api.openai.com/v1/threads/$threadID/messages/$messageID"
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $env:OPENAI_API_KEY"
        "OpenAI-Beta" = "assistants=v1"
    }
    #>
    $body = @{
        metadata = $metadata
    } | ConvertTo-Json
    # Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
    curl -X POST "https://api.openai.com/v1/threads/$threadID/messages/$messageID" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1" `
      -d $body
}
