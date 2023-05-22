<#
.Synopsis
    自己實現簡單的webRequest請求
.Description
    其實可以用內建的 Invoke-WebRequest 功能更多
.Example
    # 取得某Github的json資料
    PS> Invoke-RawWebRequest https://raw.githubusercontent.com/..."
.Example
    # Get
    PS> Invoke-RawWebRequest "http://127.0.0.1:12345/invokeRequest/" -Method GET -ContentType "application/json;charset=utf-8"
    PS> Invoke-WebRequest -Uri "http://127.0.0.1:12345/invokeRequest/" -Method GET -ContentType "application/json;charset=utf-8"
.Example
    # POST
    PS> Invoke-RawWebRequest "http://127.0.0.1:12345/invokeRequest/" "Test my Invoke-RawWebRequest" -Method POST -ContentType "text/plain"
    PS> Invoke-WebRequest -Uri "http://127.0.0.1:12345/invokeRequest/" -Body "Test my Invoke-RawWebRequest" -Method POST -ContentType "application/json;charset=utf-8"

.Link
    透過Invoke-WebRequest取得到的是一個BasicHtmlWebResponseObject型別的物件，可以參考:
    https://learn.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.basichtmlwebresponseobject?view=powershellsdk-7.2.0

    範例:
    $res = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/..." -Method Get -ContentType "application/json;charset=utf-8"
    $res.Content
#>
function Invoke-RawWebRequest {
    param (
        [Parameter(Mandatory)]
        [string]$Uri,

        [string]$Body,

        [Parameter()]
        [ValidateSet('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'TRACE', 'PATCH')]
        [string]$Method = 'GET',

        [hashtable]$Headers,
        [string]$ContentType = 'application/json;charset=utf-8',
        [Text.Encoding]$Encoding = [Text.Encoding]::UTF8,
        [switch]$UseDefaultCredentials
    )

    # Create web request object
    $webRequest = [System.Net.WebRequest]::Create($Uri)
    $webRequest.UseDefaultCredentials = $UseDefaultCredentials.IsPresent
    $webRequest.Method = $Method

    foreach ($Key in $Headers.Keys) {
        $webRequest.Headers.Add($Key, $Headers[$Key])
    }

    # Encode body with UTF8 if provided, and save as byte array
    if (-not [string]::IsNullOrWhiteSpace($Body)) {
        $ByteArray = $Encoding.GetBytes($Body)
    }

    # Set content type and length
    $webRequest.ContentType = $ContentType
    $webRequest.ContentLength = $ByteArray.Length

    # Get and write to request stream
    if (-not (@("GET", "HEAD") -contains $Method)) {
        [System.IO.Stream] $requestStream = $webRequest.GetRequestStream()
        $streamWriter = [System.IO.StreamWriter]::new($requestStream)
        $streamWriter.Write($ByteArray, 0, $ByteArray.Length)
        $streamWriter.Flush()
        $streamWriter.Dispose()
        $requestStream.Dispose()
    }

    try {
        [System.Net.WebResponse] $response = $webRequest.GetResponse()

        # Create data stream and retrieve response data
        [System.IO.Stream] $responseStream = $response.GetResponseStream()
        $streamReader = [System.IO.StreamReader]::new($responseStream)
        $responseContent = $streamReader.ReadToEnd()
        $streamReader.Dispose()
        $responseStream.Dispose()
        Write-Output $responseContent
    } catch {
        Write-Error $_.Exception.Message
    } finally {
        $response.Dispose()
    }
}


<#
.Synopsis
    為了更了解 Invoke-WebRequest 所寫的測試
.Description
    本範例著重在於傳送檔案給伺服器
.Example
    Test-InvokeWebRequest
#>
function Test-InvokeWebRequest {
    param (
        [Parameter()]
        [switch]$withCredential
    )
    $apiPath = ""
    if ($withCredential.IsPresent) {
        $apiPath = "uploadWithAuth"
    } else {
        $apiPath = "upload"
    }

    $uri = "http://127.0.0.1:12345/{0}/" -f $apiPath
    $srcFile = Get-Item (Join-Path $PSScriptRoot "../../../test/svg/keyboard.svg") -ErrorAction Stop
    $fileBytes = [System.IO.File]::ReadAllBytes($srcFile)
    $fileStr = [Text.Encoding]::UTF8.GetString($fileBytes)
    $boundary = [System.Guid]::NewGuid().ToString()

    # 如果有非ASCII的字眼要用UrlEncode，不然會是亂碼;
    $msg = ""
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $msg = [System.Web.HttpUtility]::UrlEncode("Hello world! 您好，世界！")
    } else {
        # $utf8Bytes =  [System.Text.Encoding]::UTF8.GetBytes("Hello world! 您好，世界！")
        # $msg = [System.Net.WebUtility]::UrlEncode([System.Text.Encoding]::UTF8.GetString($utf8Bytes))
        $msg = [System.Net.WebUtility]::UrlEncode("Hello world! 您好，世界！") # 無效，送到go還是亂碼
    }
    $msg2 = "12345"
    $LF = "`n"

    $bodyLines = (
        "--$boundary",
        'Content-Disposition: form-data; name=msg',
        'Content-Type: text/plain;charset=utf-8',
        '',
        "$msg",
        '',
        "--$boundary",
        'Content-Disposition: form-data; name=msg',
        'Content-Type: text/plain;charset=utf-8',
        '',
        "$msg2",
        '',
        "--$boundary",
        "Content-Disposition: form-data; name=myFile; filename=$($srcFile.Name)",
        'Content-Type: image/svg+xml',
        '',
        "$fileStr",
        "--$boundary",
        '' # 需要補上，不然會遇到錯誤: multipart: NextPart: EOF  # https://github.com/golang/go/blob/d75cc4b9c6e2acb4d0ed3d90c9a8b38094af281b/src/mime/multipart/multipart.go#L395-L402
    ) -join $LF

    $result = ""
    if ($withCredential.IsPresent) {
        $credential = Get-Credential # 會需要使用者自行輸入username, password
        if ($credential -eq $null) {
            return
        }
        # 加上Credential之後其實會訪問該網址兩次，第一次不帶憑據，Server應該回傳401 Unauthorized，要求提供憑據，在第二次請求才會包含憑據資訊
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $result = Invoke-WebRequest -Uri $uri -Credential $credential -Method Post -ContentType "multipart/form-data; boundary=$boundary" -UseBasicParsing -Body $bodyLines -AllowUnencryptedAuthentication # 因為我們用的是http非https所以如果要傳送成功需要加上-AllowUnencryptedAuthentication，不然會出現錯誤 To suppress this warning and send plain text secrets over unencrypted networks
        } else {
            # powershell 5.1沒有AllowUnencryptedAuthentication，但是即便這樣是用http的連線也不會出現unencrypted networks的錯誤;
            $result = Invoke-WebRequest -Uri $uri -Credential $credential -Method Post -ContentType "multipart/form-data; boundary=$boundary" -UseBasicParsing -Body $bodyLines
        }

    } else {
        $result = Invoke-WebRequest -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyLines
    }
    Write-Output $result
}
