function Test-IsAdministrator {
    <#
    .SYNOPSIS
        檢查當前您是否具備管理員權限
    .EXAMPLE
        ```powershell
        $r = Test-IsAdministrator
        if ($r.Err -eq $null) {
            $isAdmin = $r.Result
            Write-Output $isAdmin
        } else {
            Write-Error $r.Err
        }
        ```
    .OUTPUTS
        @{
            Result = $null
            Err = $null
        }
    #>
    $o = @{
        Result = $null
        Err = $null
    }
    try {
    	# 來取得當前的使用者身分;
    	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    	# 建立使用者主體物件;
    	$principal = New-Object Security.Principal.WindowsPrincipal($identity)

    	# 檢查是否具備管理員權限;
    	$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    	if ($isAdministrator) {
    		$o.Result = $true
    	} else {
    	    $o.Result = $false
    	}
    } catch {
    	# Write-Error "[Error] $($_.Exception.Message)"
    	$o.Err = $_.Exception.Message
    }
    return $o
}
