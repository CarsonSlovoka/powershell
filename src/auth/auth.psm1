<#
.Synopsis
    檢查當前您是否具備管理員權限
.Output
    true: isAdmin
#>
function Test-IsAdministrator {
    try {
    	# 來取得當前的使用者身分;
    	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    	# 建立使用者主體物件;
    	$principal = New-Object Security.Principal.WindowsPrincipal($identity)

    	# 檢查是否具備管理員權限;
    	$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    	if ($isAdministrator) {
    		Write-Output $true
    	} else {
    		Write-Output $false
    	}
    } catch {
    	Write-Error "[Error] $($_.Exception.Message)"
    }
}
