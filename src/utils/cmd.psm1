function Set-ByPass {
    echo "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -F"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -F
}

function Remove-PSReadlineHistory {
    <#
    .Description
        刪除所有powershell的歷史紀錄(按上鍵自動帶出的內容)
    #>
    [CmdletBinding(SupportsShouldProcess)] # -Confirm, -WhatIf,...
    param () # 如果加了CmdletBinding就必須要放;

    # Clear-History # 這個可以不需要刪除，它紀錄本視窗的歷史紀錄，視窗關閉後就不見。 可以透過 Get-History 來查詢;

    Remove-Item (Get-PSReadlineOption).HistorySavePath
}

# 注意@""@，前面@"之後一定要空行，之後"@也要在新的一行，且最後不能有多的空白！;

Set-Alias byPass Set-ByPass -Description @"
Set Scope.Process.ExecutionPolicy=Bypass
如果是在powershell 7以上似乎可以不需要特別設定即可使用;
"@ -Scope Global


<#
.Description
    It can simplify the prompt, so if your path is too long still okay.
    Implement: You are only to modify the "Prompt" function then done.
.Parameter style
    You can use tab to select the style.

    - None: do not show any text except ">" (this is default options)
    - Name: show the basename only
    - Fullpath: show the full path
.Outputs
    The output type is "string" so you must use "Invoke-Expression" to make it effective.
.Example
    Set-Prompt | iex
    Set-Prompt | Invoke-Expression
.Example
    Set-Prompt -style Name | iex
    Set-Prompt -style Fullpath | iex
.Example
    Set-Prompt -Verbose
.Link
    https://superuser.com/a/1785486/1093221
#>
function Set-Prompt {
    param (
        [Parameter()]
        [ValidateSet('None', 'Name', 'Fullpath')]
        [string]$style = "None"
    )

    [string]$myPromptFunc = ""

    switch ($style) {
        "None" {
            $myPromptFunc = 'function Prompt { ">" }'
        }
        "Name" {
            $myPromptFunc = @"
    function Prompt {
        "`$((Get-Item `$pwd).Name)>"
    }
"@
        }
        "Fullpath" {
            $myPromptFunc = 'function Prompt { Write-Output "$($pwd.Path)>" }'
        }
    }

    if ($VerbosePreference -eq "Continue") {
        Write-Host "Call " -NoNewLine
        Write-Host 'Set-Prompt | Invoke-Expression' -ForegroundColor Yellow -NoNewLine
        Write-Host " to apply."

        Write-Host "The prompt function will be changed as follow" -ForegroundColor Green
    }
    Write-Output $myPromptFunc
}
