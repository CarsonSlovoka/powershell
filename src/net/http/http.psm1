# Invoke-RawWebRequest https://raw.githubusercontent.com/..."
# Invoke-WebRequest -Uri "https://raw.githubusercontent.com/..." -Method Get -ContentType "application/json;carset=utf-8"
# https://learn.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.basichtmlwebresponseobject?view=powershellsdk-7.2.0
# $res = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/..." -Method Get -ContentType "application/json;carset=utf-8"
# $res.Content
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
    if (-not (@("Get", "HEAD") -contains $Method)) {
        # https://learn.microsoft.com/en-us/dotnet/api/system.net.webrequest.getrequeststream?view=net-7.0
        [System.IO.Stream] $requestStream = $webRequest.GetRequestStream()
        $streamWriter = [System.IO.StreamWriter]::new($requestStream)
        $streamWriter.Write($ByteArray, 0, $ByteArray.Length)
        $streamWriter.Flush()
        $streamWriter.Dispose()
        $requestStream.Dispose()
    }

    try {
        # Invoke request and get response
        # https://learn.microsoft.com/en-us/dotnet/api/system.net.webrequest.getresponse?view=net-7.0
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
