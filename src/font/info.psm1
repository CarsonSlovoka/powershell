function Get-GlyphTypeface {
    <#
    .Example
        $glyphTypeface = Get-GlyphTypeface (Join-Path $env:SystemRoot fonts/Arial.ttf)
        $glyphTypeface.Win32FamilyNames
    #>
    param (
        [Parameter(Mandatory)]
        [string]$fontPath
    )
    Add-Type -AssemblyName PresentationCore
    New-Object -TypeName Windows.Media.GlyphTypeface -ArgumentList $fontPath
}

function Get-InstallGlyphTypeface {
    <#
    .Description
        取得所有安裝(LocalMachine, CurrentUser)的所有GlyphTypeface資訊
    .Outputs
        ```
        type: [hashtable] or $null
        example:
        foo.ttf     System.Windows.Media.GlyphTypeface
        bar.TTF     System.Windows.Media.GlyphTypeface
        ...
        arial.TTF   System.Windows.Media.GlyphTypeface
        ```
    .Example
        $glyphTypefaceMap = Get-InstallGlyphTypeface
        $glyphTypefaceMap = Get-InstallGlyphTypeface -location CurrentUser
    .Example
        $glyphTypefaceMap = Get-InstallGlyphTypeface
        $glyphTypefaceMap["Arial.ttf"]
        $glyphTypefaceMap["Arial.ttf"].Win32FamilyNames

        # 查看所有的Win32FamilyNames
        $valueCollection = $glyphTypefaceMap.Values
        $valueCollection.Win32FamilyNames

        # 顯示路徑名稱與其Win32FamilyNames
        ## 只找前10筆
        $glyphTypefaceMap.GetEnumerator() | select -First 10 | foreach { "$($_.Value.FontUri.LocalPath) $($_.Value.Win32FamilyNames)"}
        ## 顯示全部
        $glyphTypefaceMap.GetEnumerator() | foreach { "$($_.Value.FontUri.LocalPath) $($_.Value.Win32FamilyNames)"}
    #>
    param (
        [Parameter()]
        [ValidateSet(
            'CurrentUser',
            'LocalMachine',
            'ALL'
        )]
        [string]$location = "ALL"
    )
    $locationMap = @{
        CurrentUser = 1
        LocalMachine = 2 # 1 -shl 1 # 1 << 1
        ALL = 3 # 1 + 1 -shl 1
    }

    $regPaths = @()
    $inputLocVal = $locationMap[$location]
    if (($inputLocVal -band ($locationMap.CurrentUser)) -eq $locationMap.CurrentUser) {
        $regPaths += 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    }
    if (($inputLocVal -band ($locationMap.LocalMachine)) -eq $locationMap.LocalMachine) {
        $regPaths += 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    }

    Add-Type -AssemblyName PresentationCore
    $glyphTypefaceMap = @{}
    foreach ($regPath in $regPaths) {
        $fontList = Get-ItemProperty $regPath
        if ($fontList -eq $null) {
            continue
        }
        foreach ($_ in ($fontList | Get-Member -MemberType NoteProperty)) {
            $propertyName = $_.Name
            if (!($propertyName.Contains("TrueType"))) {
                continue
            }
            $value = $fontList.$propertyName
            $fontPath = ""
            if (Test-Path $value) {
                $fontPath = $value
            } else {
                $fontPath = Join-Path $env:SystemRoot fonts/$value
            }

            if (!(Test-Path $fontPath)) {
                Write-Verbose "path not exits: $value" # Test-Path "C:\...\RobotoFlex[GRAD,wght].ttf" will get false even exists.
                continue
            }

            $glyphTypeface = New-Object -TypeName Windows.Media.GlyphTypeface -ArgumentList $fontPath
            $name = (Get-Item ($glyphTypeface.FontUri.LocalPath)).Name # xxx.ttf
            $glyphTypefaceMap[$name] = $glyphTypeface
        }
    }
    if ($glyphTypefaceMap.Count -eq 0) {
        return $null
    }
    return $glyphTypefaceMap
}
