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
          "status": "queued", # 這個是狀態，這個表示排隊中, in_progress, requires_action, cancelling, cancelled, failed, completed, expired
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
          "usage": null # 如果status為in_progress, queued,也就是還沒執行完，那麼這都會是null，如果完成可以看到tokens的用量
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


