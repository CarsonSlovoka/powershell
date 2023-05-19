<#
.Synopsis
    使用Add-AppxPackage來安裝AppxManifest.xml
.Description
    因為安裝自定義的項目需要將"開發人員模式"打開才行

    所以會先判斷是否為開發人員模式，如果是關閉的狀態，會先打開，最後執行完之後會再關閉; 如果已經開啟，那麼就直接安裝
.Parameter appManifestXmlPath
  請輸入AppxManifest.xml的路徑
.Example
    # 絕對路徑
    Install-App "C:\..\src\AppxManifest.xml"
.Example
    # 相對路徑
    Install-App "./src/AppxManifest.xml"
    Install-App "AppxManifest.xml"
#>
function Install-App {
    param (
        [Parameter(Mandatory=$true)]
        [string] $appManifestXmlPath
    )

    if (-not (Test-Path -Path "$appManifestXmlPath")) {
        Write-Error "[path not found error] $appManifestXmlPath"
        return
    }

    # 在管理通知中的 允許開發人員 選項就是透過這個機碼來決定的
    [bool] $needCloseDev = $false
    if ( (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock").AllowDevelopmentWithoutDevLicense -eq $null ) { # 此數值如果沒有啟用過，會不存在
        # 當不存在的時候，我們就先啟用後關閉
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction Stop
        $needCloseDev = $true
    } elseif ( (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock").AllowDevelopmentWithoutDevLicense -eq 0) {
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction Stop
        $needCloseDev = $true
    }

    Add-AppxPackage -Path "$appManifestXmlPath" -Register -Confirm

    # 依據displayName來查詢是否有被添加到StartApps之中
    [xml]$appManifestXml = Get-Content -Path "$appManifestXmlPath" # 可用相對路徑: Get-Content -Path "AppxManifest.xml"
    $displayName = $appManifestXml.Package.Applications.Application.VisualElements.DisplayName
    Get-StartApps -Name "$displayName" | Select-Object Name, AppID

    if ($needCloseDev) {
      echo "reset AllowDevelopmentWithoutDevLicense to origin: 0"
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 0
      Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    }
}

<#
.Synopsis
    移除Add-AppxPackage來安裝的項目
.Description
    依據您給的Package.Identity.Name去使用Get-AppxPackage來獲得到PackageFullName

    接著使用PackageFullName去Remove-AppxPackage
.Parameter packageIdName
  Package.Identity.Name

  該項目位於AppManifest.xml之中，例如

  <Identity Name="IdExampleApp" Publisher="CN=Example" Version="1.0.0.0" />

.Example
    # 透過Package.Identity.Name去移除
    Uninstall-App "IdExampleApp"

    # 如果您已經知道$packageFullName那麼可以直接透過系統指令Remove-AppxPackage去刪除
    Remove-AppxPackage -Package "ExampleApp_1.0.0.0_neutral__s2ne61n4j7kre"

.Example
    # 如果不確定名稱可以用萬用字元，但要確定避免誤刪
    Uninstall-App "*Example*"
#>
function Uninstall-App {
    param (
        [Parameter(Mandatory=$true)]
        [string] $packageIdName
    )

    $packageFullName = Get-AppxPackage -Name "$packageIdName" # 記住他的PackageFullName
    if ($packageFullName -eq $null) {
        Write-Error "Package.Identity.Name not found error. $packageIDName"
        return
    }

    Remove-AppxPackage -Package "$packageFullName" -Confirm
}
