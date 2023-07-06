function Find-Window {
    <#
    .Synopsis
        user32.dll.FindWindow(className, windowName)
    .Description
    .Parameter title
        Dialog的標題內容
    .Outputs
        @{
           Hwnd = 0
           Err = $null
        }
    .Example
        Find-Window 'ConsoleWindowClass' 'Windows PowerShell'
        Find-Window ApplicationFrameWindow 小算盤
        fWin 'ConsoleWindowClass' 'Windows PowerShell'
    .Example
        # class only
        Find-Window Notepad
    .Example
        Find-Window -windowName 小算盤
        Find-Window -windowName Calculatrice
    .Link
        https://stackoverflow.com/a/48698671/9935654
    #>
    [alias('fWin')]
    param (
        [Parameter()]
        [string]$className = "",
        [Parameter()]
        [string]$windowName = ""
    )

    $sig=@'
    // Note: Must declare all type, Otherwise will not work on Null
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, IntPtr lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(IntPtr lpClassName, string lpWindowName);

    [DllImport("kernel32.dll")]
    public static extern uint GetLastError();
'@

    $w32 = Add-Type -Namespace Win32 -Name Funcs -MemberDefinition $sig -PassThru
    <#
    if ($PSVersionTable.PSVersion.Major -ge 7) { // 不行這樣，在低於7的版本，語法解析時候就會報錯
        $cName = $className -eq "" ? [IntPtr]::Zero : $className
        $wName = $windowName -eq "" ? [IntPtr]::Zero : $windowName
    } else {
        $cName = if ($className -eq "") {[IntPtr]::Zero} else {$className}
        $wName = if ($windowName -eq "") {[IntPtr]::Zero} else {$windowName}
    }
    #>
    $cName = if ($className -eq "") {[IntPtr]::Zero} else {$className}
    $wName = if ($windowName -eq "") {[IntPtr]::Zero} else {$windowName}
    $r = $w32::FindWindow($cName, $wName)
    $o = @{
       Hwnd = 0
       Err = $null
    }
    if ($r -eq 0) {
        $o.Err = $w32::GetLastError()
        return $o
    }
    $o.Hwnd = $r
    return $o
}
