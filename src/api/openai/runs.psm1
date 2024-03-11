function Request-OpenAI-CreateRun {
    <#
    .SYNOPSIS
        在該thread下，運行某一個assistant
    .DESCRIPTION
        其他相關參數請自己加入到body之中
        - asstID 必填
        - instructions
        - additionalInstructions
        - tools
        - metadata
    .PARAMETER threadID
    .EXAMPLE
        # 必填項目
        $body = @{
            assistant_id = 'asst_...'
        }
        Request-OpenAI-CreateRun thread_... $body
    .EXAMPLE
        # metadata可以當成備註
        $body = @{
            assistant_id = 'asst_...'
            metadata = @{
                author = 'Carson'
                time = Get-Date
            }
        }
        Request-OpenAI-CreateRun thread_... $body
    .EXAMPLE
        # 所有可填入資訊的範例
        $body = @{
            assistant_id = ''
            # model = '' # 可以覆蓋原本的模型
            # instructions = '' # 覆蓋原本的指導準則
            # additional_instructions = '' # 添加指導準則
            metadata = @{
                        author: 'Carson'
                        time: Get-Date
            },
            tools = @(
                @{
                    type = "code_interpreter"
                },
                @{
                    type = "retrieval"
                },
                @{
                    type = "function"
                    function = @{
                        name = "" # 必填
                        description = "" # 可選
                        parameters = @{ # 如果沒有參數可以直接省略
                            # 可以填的內容，請參考: https://json-schema.org/understanding-json-schema
                        }
                    }
                },
                 @{ # 再加入第二個函數，以此類推
                    type = "function"
                    function = @{
                        }
                    }
                }
            )
        }
    .OUTPUTS
        {
          "id": "run_...",
          "object": "thread.run",
          "created_at": 1710143630,
          "assistant_id": "asst_...",
          "thread_id": "thread_...",
          "status": "completed", # queued 這個是狀態，這個表示排隊中, in_progress, requires_action, cancelling, cancelled, failed, completed, expired
          "started_at": null,
          "expires_at": 1710144230,
          "cancelled_at": null,
          "failed_at": null,
          "completed_at": null,
          "required_action": null,
          "last_error": null,
          "model": "gpt-3.5-turbo-0125", # 當前用哪一個模型
          "instructions": "將使用者輸入的內容翻譯成英文", # 指導原則是什麼
          "tools": [], # code_interpreter, retrieval, function之類的東西
          "file_ids": [], # 有沒有用到檔案
          "metadata": { # 自定義的meta訊息
            "time": "2024-03-11T15:53:48.8038518+08:00",
            "author": "Carson"
          },
          "usage": { # 如果status為in_progress, queued,也就是還沒執行完，那麼這都會是null，如果完成可以看到tokens的用量
            "prompt_tokens": 57, # 您所輸入的token (這個價錢比較便宜)
            "completion_tokens": 11, # 輸出的token (花費比較貴)
            "total_tokens": 68 # 組token
          }

        }
    .LINK
        https://platform.openai.com/docs/api-reference/runs/createRun
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [hashtable]$body
    )

    curl -X POST "https://api.openai.com/v1/threads/$threadID/runs" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1" `
      -d ($body | ConvertTo-Json)
}

function Request-OpenAI-ListRuns {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER threadID
    .PARAMETER limit
        1~100 顯示多少則訊息
    .PARAMETER order
        desc, asc
    .PARAMETER after
        往後查詢: 在哪一個訊息id之後
    .PARAMETER before
        往前查詢: 在哪一個訊息id之前
    .EXAMPLE
        Request-OpenAI-ListRuns thread_...
    .LINK
        https://platform.openai.com/docs/api-reference/runs/listRuns
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,

        [int]$limit = 20, # 1~100
        [string]$order = 'asc', # desc, asc
        [string]$after = '',
        [string]$before = ''
    )

    curl "https://api.openai.com/v1/threads/$threadID/runs?limit=$limit&order=$order&after=$after&before=$before" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1"
}

function Request-OpenAI-GetRun {
    <#
    .SYNOPSIS
        列出thread下的某一個Run
    .DESCRIPTION
        與Request-OpenAI-ListRuns的結果差不多，只是這個只返回特定的某一筆資料
    .PARAMETER threadID
    .PARAMETER runID
    .EXAMPLE
        Request-OpenAI-ListRuns thread_... run_...
    .LINK
        https://platform.openai.com/docs/api-reference/runs/getRun
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID
    )

    curl "https://api.openai.com/v1/threads/$threadID/runs/$runID" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1"
}

function Request-OpenAI-ListRunSteps {
    <#
    .SYNOPSIS
        列出所有Thread下所指定的runID其所有的stepID，也能得到相關的msgID
    .DESCRIPTION
        再取得msgID之後可以呼叫
        Request-OpenAI-GetThreadMsg threadID msgID
        來得到message的內容
    .PARAMETER threadID
    .PARAMETER runID
    .PARAMETER limit
        1~100 顯示多少則訊息
    .PARAMETER order
        desc, asc
    .PARAMETER after
        往後查詢: 在哪一個訊息id之後
    .PARAMETER before
        往前查詢: 在哪一個訊息id之前
    .EXAMPLE
        Request-OpenAI-ListRunSteps thread_... run_...
    .OUTPUTS
    {
      "object": "list",
      "data": [
        {
          "id": "step_...", # 可以獲得stepID
          "object": "thread.run.step",
          "created_at": 1710143631,
          "run_id": "run_...",
          "assistant_id": "asst_...",
          "thread_id": "thread_...",
          "type": "message_creation",
          "status": "completed",
          "cancelled_at": null,
          "completed_at": 1710143631,
          "expires_at": null,
          "failed_at": null,
          "last_error": null,
          "step_details": {
            "type": "message_creation",
            "message_creation": {
              "message_id": "msg_..." # 獲得這個msgID
            }
          },
          "usage": {
            "prompt_tokens": 57,
            "completion_tokens": 11,
            "total_tokens": 68
          }
        }
      ],
      "first_id": "step_...",
      "last_id": "step_...",
      "has_more": false
    }
    .LINK
        https://platform.openai.com/docs/api-reference/runs/listRunSteps
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID,

        [int]$limit = 20,
        [string]$order = 'asc',
        [string]$after = '',
        [string]$before = ''
    )

    curl "https://api.openai.com/v1/threads/$threadID/runs/$runID/steps?limit=$limit&order=$order&after=$after&before=$before" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1"
}

function Request-OpenAI-ModifyRun {
    <#
    .SYNOPSIS
    .DESCRIPTION
        查看
        Request-OpenAI-GetRun thread_ run_
    .PARAMETER threadID
    .PARAMETER runID
    .EXAMPLE
        $body = @{
           metadata = @{
            key1 = "value1"
            keyN = "valueN"
           }
        }
        Request-OpenAI-ModifyRun thread_... run_... $body
    .LINK
        https://platform.openai.com/docs/api-reference/runs/modifyRun
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID,
        [Parameter(Mandatory=$true)]
        [hashtable]$body
    )

    curl -X POST "https://api.openai.com/v1/threads/$threadID/runs/$runID" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1" `
      -d ($body | ConvertTo-Json)
}

function Request-OpenAI-CancelRun {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER threadID
    .PARAMETER runID
    .EXAMPLE
        Request-OpenAI-CancelRun thread_... run_... $body
    .OUTPUTS
        {
          "error": {
            "message": "Cannot cancel run with status 'completed'.", # 表示這個已經是完成的狀態，因此沒辦法再取消
            "type": "invalid_request_error",
            "param": null,
            "code": null
          }
        }
    .LINK
        https://platform.openai.com/docs/api-reference/runs/cancelRun
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID
    )

    curl -X POST "https://api.openai.com/v1/threads/$threadID/runs/$runID/cancel" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H "OpenAI-Beta: assistants=v1"
}
