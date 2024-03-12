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
        Request-OpenAI-CreateRun thread_... @{assistant_id = 'asst_...'}
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
    .EXAMPLE
        # 列出thread最後一筆的run物件
        Request-OpenAI-ListRuns thread_... 1 'desc'

        # 如果有用到函數，那麼會出現required_action，例如:
        "required_action": { # 要輸入之後才能繼續動作
            "type": "submit_tool_outputs"
            "submit_tool_outputs": {
              "tool_calls": [
                {
                  "id": "call_", # 這個是您定義的function參數
                  "type": "function",
                  "function": {
                    "name": "get_stock_price", # function名稱
                    "arguments": "{\"symbol\":\"TSM\"}" # 然後AI會自己猜你的參數
                  }
                }
              ]
            }
        }
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
        如果你用playground，執行的期間，旁邊有一個按鈕，按了也可以取消
    .PARAMETER threadID
    .PARAMETER runID
    .EXAMPLE
        Request-OpenAI-CancelRun thread_... run_...
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

function Request-OpenAI-SubmitToRun {
    <#
    .SYNOPSIS
    .DESCRIPTION
        完成之後可以使用，來查看返回的內容
        Request-OpenAI-ListThreadMsg "thread_" 1 'desc'
    .PARAMETER threadID
    .PARAMETER runID
    .PARAMETER callID
        在event為thread.run.requires_action之中的required_action裡面的tool_calls中可以找到callID
        你所呼叫的函數id名稱，注意這個函數的id每次都不一樣，他會結合參數來成為一個唯一的參數，所以每次都不同
        callID可以透過此來查詢: Request-OpenAI-ListRuns thread_ 1 'desc'
    .PARAMETER output
        看你有沒有想要調整，沒有就直接打上OK即可
    .EXAMPLE
        # 查詢相關id:
        Request-OpenAI-ListRuns thread_ 1 'desc'

        # 執行
        Request-OpenAI-SubmitToRun thread_... run_... call_...
    .EXAMPLE
        Request-OpenAI-SubmitToRun thread_... run_... call_... 'OK'
    .LINK
        https://platform.openai.com/docs/api-reference/runs/submitToolOutputs
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID,
        [Parameter(Mandatory=$true)]
        [string]$callID,

        [string]$output = "OK"
    )

    $body = @{
        tool_outputs = @( # 有可能一個請求裡面有用到多個函數，因此這邊其實是一個array
            @{
                tool_call_id = $callID
                output = $output
            }
        )
    }

    # Wait-Debugger
    Request-OpenAI-SubmitToRunEx $threadID $runID $body.tool_outputs
}

function Request-OpenAI-SubmitToRunEx {
    <#
    .SYNOPSIS
    .DESCRIPTION
        完成之後可以使用，來查看返回的內容
        Request-OpenAI-ListThreadMsg "thread_" 1 'desc'
    .PARAMETER threadID
    .PARAMETER runID
    .PARAMETER toolOutputs
    .EXAMPLE
        # 查找最後一筆run訊息，取得相關id
        Request-OpenAI-ListRuns thread_ 1 'desc'

        $toolOutputs = @(
            @{
                tool_call_id= "call_"
                # output = 'location: Taoyuan' # 如果這樣變成你要指導他輸出的內容，也就是如果你查詢是台北市，那麼它的輸出可能會變成: 很抱歉，我們只能獲得桃園市的天氣資訊，而不是新北市...
                output = 'OK' # 因此建議不要去修改output
            },
            @{
                tool_call_id= "call_"
                output = "OK"
            }
        )
        Request-OpenAI-SubmitToRunEx thread_... run_... $toolOutputs
    .LINK
        https://platform.openai.com/docs/api-reference/runs/submitToolOutputs
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$threadID,
        [Parameter(Mandatory=$true)]
        [string]$runID,
        [Parameter(Mandatory=$true)]
        [array]$toolOutputs
    )

    $body = @{
        tool_outputs = $toolOutputs
    }

    curl -X POST "https://api.openai.com/v1/threads/$threadID/runs/$runID/submit_tool_outputs" `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H 'Content-Type: application/json' `
      -H 'OpenAI-Beta: assistants=v1' `
      -d ($body | ConvertTo-Json)

    # Start-Sleep -Seconds 3

    # 呼叫完如果馬上執行，有可能AI還再生成，所以結果不會馬上出來，手動去呼叫
    Write-Host "請呼叫以下函數取得回應結果"
    Write-Host ('Request-OpenAI-ListThreadMsg {0} 1 desc' -f $threadID) -ForegroundColor Green
}
