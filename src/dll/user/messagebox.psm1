 <#
.Example
    MessageBox "body message" "title" OK
.Example
    MessageBox "body message" "title" YesNo
.Example
    MessageBox "body message" "title" YesNo  Question
.Link
    https://learn.microsoft.com/zh-tw/dotnet/api/system.windows.forms.messagebox?view=windowsdesktop-7.0
#>
function MessageBox {
    param (
        [string]$body,
        [string]$title,

        # 使用者種方式可以設定可選項，讓tab會自動在這些可選項切換，此外如果可選項不對，他也會告知
        [Parameter(Mandatory=$true)]
        [ValidateSet('OK', 'OKCancel', 'YesNo', 'RetryCancel')]
        [string]$btnStyle,

        [Parameter(Mandatory=$false)]
        [ValidateSet('None', 'Warning', 'Question', 'Error')]
        [string]$iconStyle = "None"
    )
    Add-Type -AssemblyName System.Windows.Forms

    # https://learn.microsoft.com/zh-tw/dotnet/api/system.windows.forms.messageboxbuttons?view=windowsdesktop-7.0
    $btnMap = @{
        OK = [System.Windows.Forms.MessageBoxButtons]::OK;
        OKCancel = [System.Windows.Forms.MessageBoxButtons]::OKCancel;
        YesNo = [System.Windows.Forms.MessageBoxButtons]::YesNo;
        RetryCancel = [System.Windows.Forms.MessageBoxButtons]::RetryCancel;
    }

    # https://learn.microsoft.com/zh-tw/dotnet/api/system.windows.forms.messageboxicon?view=windowsdesktop-7.0
    $iconMap = @{
        None = [System.Windows.Forms.MessageBoxIcon]::None;
        Warning = [System.Windows.Forms.MessageBoxIcon]::Warning;
        Question = [System.Windows.Forms.MessageBoxIcon]::Question;
        Error = [System.Windows.Forms.MessageBoxIcon]::Error;
    }

    [System.Windows.Forms.MessageBox]::Show($body, $title, $btnMap[$btnStyle], $iconMap[$iconStyle])
}
