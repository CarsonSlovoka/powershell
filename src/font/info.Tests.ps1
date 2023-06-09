Describe "[font.info.psm1]" {
    if (!(
        (Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts") -and
        (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts")
      )) {
        Write-Host '"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" not found'
        return # 就不繼續往下測試;
    }

    $fontPath = Join-Path $env:SystemRoot fonts/Arial.ttf
    if (!(Test-Path $fontPath)) {
        Write-Host "$fontPath not found"
        return
    }

    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'info.psm1')
        $fontPath = Join-Path $env:SystemRoot fonts/Arial.ttf
    }

    It "Calls Get-GlyphTypeface" {
        $glyphTypeface = Get-GlyphTypeface $fontPath -ErrorAction SilentlyContinue
        $glyphTypeface | Should -Not -BeNullOrEmpty
    }

    It "Calls Get-InstallGlyphTypeface" {
        $glyphTypefaceMap = Get-InstallGlyphTypeface -location CurrentUser -ErrorAction SilentlyContinue
        $glyphTypefaceMap | Should -Not -BeNullOrEmpty
        $glyphTypefaceMap = Get-InstallGlyphTypeface -location LocalMachine -ErrorAction SilentlyContinue
        $glyphTypefaceMap | Should -Not -BeNullOrEmpty

        # ALL
        $glyphTypefaceMap = Get-InstallGlyphTypeface -ErrorAction SilentlyContinue
        $glyphTypefaceMap | Should -Not -BeNullOrEmpty

        # $glyphTypefaceMap.GetEnumerator() | select -First 10 | foreach { "$($_.Value.FontUri.LocalPath) $($_.Value.Win32FamilyNames)"}
        # $glyphTypefaceMap.GetEnumerator() | foreach { "$($_.Value.FontUri.LocalPath) $($_.Value.Win32FamilyNames)"}
    }
}
