function Get-WiFiPassword([string]$deviceName = "") {
    if($deviceName -eq "") {
        echo "please input a name as follow:"
        netsh wlan show profiles # 顯示所有使用者資訊
        return
    }

    # 查詢該設備的密碼 # 如果`key=clear`您還是看不到密碼，可能是因為權限的關係所導致，用admin權限即可解決。;
    netsh wlan show profile "$deviceName" key=clear
}

Set-Alias gWiPsw Get-WiFiPassword
Set-Alias Get-WiFlyPassword Get-WiFiPassword
