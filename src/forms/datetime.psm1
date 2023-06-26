function Show-DateTime {
<#
    .Synopsis
        將日期和時間顯示在一個dialog之中
    .Description
        透過Get-Date來取得當前的日期時間，並利用Form來呈現
    .Parameter title
        Dialog的標題內容
    .Example
        Show-DateTime
    .Example
        Show-DateTime "現在時間"
    #>
    param (
        [Parameter()]
        [string]$title="Current Time"
    )

    # https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms?view=windowsdesktop-7.0
    Add-Type -AssemblyName System.Windows.Forms

    $form =  [System.Windows.Forms.Form]::new()
    $form.Text = $title
    $form.Size = [System.Drawing.Size]::new(300, 100)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

    $label = [System.Windows.Forms.Label]::new()
    $label.Text = (Get-Date).ToString("hh:mm:ss tt")
    $label.AutoSize = $true
    $label.Location = [System.Drawing.Point]::new(10, 20)

    $form.Controls.Add($label)

    $timer = [System.Windows.Forms.Timer]::new()

    $form.add_FormClosing({
        $timer.Stop()
    })

    $timer.Interval = 1000
    $timer.Add_Tick({
        $label.Text = (Get-Date).ToString("hh:mm:ss tt")
    })

    $timer.Start()
    $form.ShowDialog() | Out-Null
}
