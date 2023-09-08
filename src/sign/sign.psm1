function Add-DigitalSignup {
    <#
    .Synopsis
        將應用程式進行數位加簽
    .Parameter exePath
        要被加簽的應用程式路徑
    .Parameter acFile
        MSCV-VSClass3.crt
    .Parameter signCertFile
        mypfx.pfx
    .Example
        Add-DigitalSignup (Get-Item 'C:\..\my.exe') `
            (Get-Item 'C:\xxx\my.crt') `
            (Get-Item 'C:\xxx\my.pfx') `
            -password '123' `
            -subjectName 'xxx Taiwan Inc'
    .Link
        https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe
    #>
    param (
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$exePath,

        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$acFile,

        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$signCertFile, # pfx

        [Parameter()]
        [string]$subjectName, # /n

        [Parameter()]
        [string]$password, # /p

        [Parameter()]
        [string]$tURL = 'http://timestamp.digicert.com' # /t
    )

    # $orgLocation = (pwd).Path
    # cd (Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/')

    <#
    ${env:ProgramFiles(x86)}\Windows Kits\10\App Certification Kit\signtool.exe <-- we want this one.
    ${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.17763.0\arm\signtool.exe
    ...
    ${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.17763.0\x64\signtool.exe
    #>
    # $signToolExePath = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/10/App Certification Kit/signtool.exe'
    $signToolExePath = Get-ChildItem -Path (Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/') -Recurse -Filter "*signtool.exe" -File `
        | Select-Object -ExpandProperty FullName ` # return Object[]
        | Where-Object {$_ -like '*App Certification Kit*'} `
        | Select-Object -First 1

    $params = @(
        # required
        'sign /v',
        ('/ac "{0}"' -f $acFile),
        ('/f "{0}"' -f $signCertFile),
        ('/t "{0}"' -f $tURL)
    )

    # options
    if ($subjectName -ne "") {
        $params += '/n "{0}"' -f $subjectName
    }

    if ($password -ne "") {
        $params += '/p "{0}"' -f $password
    }

    $params += '"{0}"' -f $exePath

    # echo $signToolExePath ([String]::Join(' ', $params))
    Start-Process $signToolExePath ([String]::Join(' ', $params))
}
