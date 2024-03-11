function Request-OpenAI-Help {
    Write-Host '有關於返回值，他的時間是Unix的second'
    Write-Host '- 這種方法是UTC+0的時間: [datetime]::UnixEpoch.AddSeconds(1709878845).ToString("yyyy/MM/dd HH:mm:ss")'
    Write-Host '>> 2024/03/08 06:20:45'
    Write-Host '- Get-Date -UnixTimeSeconds 1709878845'
    Write-Host '>> 2024年3月8日 下午 02:20:45'
    Write-Host 'Playground'
    Write-Host 'https://platform.openai.com/playground?assistant=<assistantID>&mode=assistant&thread=<threadID>'
    Write-Host 'https://twitter.com/OpenAIDevs'
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
