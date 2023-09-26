function url-encode {
    <#
    .Link
        https://www.mongodb.com/docs/atlas/troubleshoot-connection/#special-characters-in-connection-string-password
    #>
    param (
        [string]$text
    )

    return $text -replace ":", "%3A" `
                -replace "/", "%2F" `
                -replace "\?", "%3F" `
                -replace "#", "%23" `
                -replace "\[", "%5B" `
                -replace "\]", "%5D" `
                -replace "@", "%40"
}

function New-MongoConnectByDNS {
    <#
    .Synopsis
        使用mongosh連線到MongoDB的服務器

    .Parameter hostName
        前面可能是clusterName加上後面的一串東西，例如:
        my-cluster.jkj8c.mongodb.net/

    .Parameter username
        指的是資料庫的使用者

        可以在Database Access的頁面設定使用者

        > https://cloud.mongodb.com/v2/88888888888888888888888#/security/database/users
    .Parameter password
        如果沒給會提示輸入
    .Example
        New-MongoConnectByDNS my-cluster.jkj8c.mongodb.net Jack
    .Example
        New-MongoConnectByDNS my-cluster.jkj8c.mongodb.net Jack pswXXX
    .Link
        https://cloud.mongodb.com/
    #>

    param (
        [Parameter(Mandatory)]
        [string]$hostName,

        [Parameter(Mandatory)]
        [string]$username,

        [Parameter()]
        [string]$password,

        [Parameter()]
        [string]$protocol = 'mongodb+srv'
    )

    $mongoShExePath = (gcm mongosh.exe -ErrorAction SilentlyContinue).Path

    if ($mongoShExePath -eq $null) {
        Write-Error "couldn't find the mongosh.exe. download: https://www.mongodb.com/try/download/shell"
        return
    }

    [string]$para = ''
    if ($password.Length -eq 0) {
        # 這種情況會自動跳出password的提示輸入，它會自動進行unl-encoded所以直接打原密碼即可
        $para = ('{0}://{1}/ --apiVersion 1 --username {2}' -f $protocol, $hostName, $username)
    } else {
        $password = url-encode $password
        $para = ('{0}://{1}:{2}@{3}/' -f $protocol, $username, $password, $hostName)
    }

    Write-Verbose $para

    Start-Process $mongoShExePath $para `
        -NoNewWindow -Wait # NoNewWindow可以直接在powershell之中開啟不會有新視窗跑出來，要加上Wait才會干擾(等待mongosh結束)
}

function New-MongoConnectByIP {
    <#
    .Synopsis
        使用mongosh連線到由mongod所產生的server

        mongod.exe --config "C:\xxx\mongo.conf"

    .Parameter ip
        127.0.0.1
        or
        123.123.123.123
    .Parameter port
        12345
        27017
        ...
    .Parameter username

    .Parameter password

    .Parameter database
        要連到哪一個資料庫去(可選)
    .Example
        New-MongoConnectByIP  127.0.0.1  27017
    .Example
        New-MongoConnectByIP 127.0.0.1 17823 -database myDB
    .Example
        New-MongoConnectByIP  127.0.0.1  27017  UserName Psw
    .Example
        New-MongoConnectByIP  123.123.123.123  27017  UserName Psw  myDB # 這好像會連不上
    .Link
        [mongod的啟動可以參考](https://github.com/CarsonSlovoka/CarsonSlovoka.github.io/blob/73e932316451fb00caa5e35c5a95fca8708aa4ce/src/url/blog/db/mongodb.md?plain=1#L195-L236)
    #>

    param (
        [Parameter(Mandatory)]
        [ValidateScript({
            $pattern = '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'
            if ($_ -match $pattern) {
                return $true
            }
            throw "Invalid IP address. $_"
        })][string]$ip,

        [Parameter(Mandatory)]
        [int]$port,

        [Parameter()]
        [string]$username,

        [Parameter()]
        [string]$password,

        [Parameter()]
        [string]$database
    )
    $mongoShExePath = (gcm mongosh.exe -ErrorAction SilentlyContinue).Path

    if ($mongoShExePath -eq $null) {
        Write-Error "couldn't find the mongosh.exe. download: https://www.mongodb.com/try/download/shell"
        return
    }

    [string]$para = ''
    if ($username.Length -gt 0) {
        $para = ("mongodb://{0}:{1}@{2}:{3}/{4}" -f $username, $password, $ip, $port, $database)
    } else {
        $para = ("mongodb://{0}:{1}/{2}" -f $ip, $port, $database)
    }

    Write-Verbose $para

    Start-Process $mongoShExePath $para `
        -NoNewWindow -Wait
}
