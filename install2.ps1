$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdministrator) {
    Write-Error "Please run as admin."
    return
}

# 設定參數
$repoOwner = "CarsonSlovoka"
$repoName = "powershell"
$releaseTag = "0.1.0"
$extractPath = "."

# 下載發行版(zip檔案)
$downloadUrl = "https://github.com/$repoOwner/$repoName/archive/refs/tags/v$releaseTag.zip"
$zipFilePath = Join-Path $Env:Temp "$repoOwner-$repoName-$releaseTag.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath

# 解壓縮zip檔案到指定資料夾
Expand-Archive -Path $zipFilePath -DestinationPath $extractPath

# 刪除下載的壓縮檔
Remove-Item $zipFilePath

# 切換到解壓縮後的資料夾
# 解壓縮的檔案固定是用$repoName-$releaseTag的組合，所以幫它重新命名，避免安裝多個不同版本的項目
Rename-Item "$extractPath\$repoName-$releaseTag" "$repoOwner-$repoName"
cd "$extractPath\$repoOwner-$repoName"

# 執行安裝檔文件
pwsh.exe -ExecutionPolicy ByPass -File install.ps1
