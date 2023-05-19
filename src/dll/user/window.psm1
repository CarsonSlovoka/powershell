# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.3#example-4-call-native-windows-apis
# 如果在函數的Help之前在加上#註解，會導致函數Help無法正常顯示，如果前面真的有註解就要在多空一行出來;

<#
.SYNOPSIS
    視窗操作相關
.DESCRIPTION
    您可以將某視窗進行: {最小化、最大化、視窗還原、...}的操作

    如果您需要更完整的用法可以執行以下命令:
    (Get-Command Show-WindowAsync).ParameterSets | Select-Object -Property @{n='ParameterSetName';e={$_.name}}, @{n='Parameters';e={$_.ToString()}}
.PARAMETER name
    會使用 `Get-Process -Name` 來查詢您輸入的name名稱
    如果該名稱有多個被查找到，以使用第一個名稱的PID為主
.PARAMETER nCmdShow
    2: min window
    4: show no active
    5: show
    更多請參考: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
.INPUTS
    name
    nCmdShow
.OUTPUTS
    true: Success
    false: Fail
.NOTES
    Author: Carson Tseng
    Date:   2023/04/28
.EXAMPLE
    PS> Show-WindowAsync -name notepad++ -swName SW_SHOWMINIMIZED
    PS> Show-WindowAsync -name notepad++ -swID 2
    true
.EXAMPLE
    PS> Show-WindowAsync -name notepad++ -swName SW_SHOWNOACTIVATE
    PS> Show-WindowAsync -name note* -swID 4
    true
.EXAMPLE
    PS> Show-WindowAsync -name notepad++ -swName SW_RESTORE
    PS> Show-WindowAsync -name note* -swID 9
.LINK
    https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.3#example-4-call-native-windows-apis
#>
function Show-WindowAsync {
    [CmdletBinding(DefaultParameterSetName='byStr')]
    param (
        [Parameter(Mandatory=$true)]
        [string] $name,

        [Parameter(ParameterSetName='byNumber', Mandatory=$true)]
        [int] $swID,

        [Parameter(ParameterSetName='byStr', Mandatory=$true)]
        [ValidateSet(
            'SW_HIDE',
            'SW_SHOWNORMAL', 'SW_NORMAL',
            'SW_SHOWMINIMIZED',
            'SW_SHOWMAXIMIZED', 'SW_MAXIMIZE',
            'SW_SHOWNOACTIVATE',
            'SW_SHOW',
            'SW_MINIMIZE',
            'SW_SHOWMINNOACTIVE',
            'SW_SHOWNA',
            'SW_RESTORE',
            'SW_SHOWDEFAULT',
            'SW_FORCEMINIMIZE'
        )]
        [string] $swName
    )

#    '@  前面不能有空行 White space is not allowed before the string terminator.

    $Signature = @"
    [DllImport("user32.dll")]public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@

    $ShowWindowAsync = Add-Type -MemberDefinition $Signature -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

    $process = Get-Process -Name $name
    $targetPID = 0
    if ($process -is [array]) {
        $targetPID = $process[0].Id
    } else {
        $targetPID = $process.Id
    }

    [int]$nCmdShow = 0
    if ($PSCmdlet.ParameterSetName -eq 'byNumber') {
        $nCmdShow = $swID
    } else {
        $swMap = @{
            'SW_HIDE' = 0
            'SW_SHOWNORMAL' = 1
            'SW_NORMAL' = 1

            'SW_SHOWMINIMIZED' = 2

            'SW_SHOWMAXIMIZED' = 3
            'SW_MAXIMIZE' = 3

            'SW_SHOWNOACTIVATE' = 4
            'SW_SHOW' = 5
            'SW_MINIMIZE' = 6
            'SW_SHOWMINNOACTIVE' = 7
            'SW_SHOWNA' = 8
            'SW_RESTORE' = 9
            'SW_SHOWDEFAULT' = 10
            'SW_FORCEMINIMIZE' = 11
        }
        $nCmdShow = $swMap[$swName]
    }

    # https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
    # 2: min
    # 4: show no active
    # 5: show
    # $ShowWindowAsync::ShowWindowAsync((Get-Process -Name notepad++).Id, 2)
    # $ShowWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
    # $ShowWindowAsync::ShowWindowAsync((Get-Process -Id (Get-Process -Name notepad++).Id).MainWindowHandle, 2)
    # echo (Get-Process -Id $targetPID | format-list)
    $ShowWindowAsync::ShowWindowAsync((Get-Process -Id $targetPID).MainWindowHandle, $nCmdShow) # 如果最後回傳False代表執行失敗
}
# https://learn.microsoft.com/zh-tw/powershell/module/microsoft.powershell.core/export-modulemember?view=powershell-7.3#5
Set-Alias swa ShowWindowAsync
# pwsh應該是使用UTF8的編碼，所以中文的Description可以正常顯示，至於powershell5.1會是亂碼
Set-Alias showWinA ShowWindowAsync -Description "視窗操作相關" -Scope Global # 要補上Scope才會讓Description可以被看見

# Export-ModuleMember -Function ShowWindowAsync -Alias swa, showWinA
# Export-ModuleMember -Function ShowWindowAsync -Alias swa # 不需要加這邊統一給psd1加就行了
