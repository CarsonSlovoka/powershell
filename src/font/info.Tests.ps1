Describe "[font.info.psm1]" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'info.psm1')
        $fontPath = Join-Path $env:SystemRoot fonts/Arial.ttf
    }
    It "Calls Get-GlyphTypeface" {
        if (Test-Path $fontPath) {
            $glyphTypeface = Get-GlyphTypeface $fontPath -ErrorAction SilentlyContinue
            $glyphTypeface | Should -Not -BeNullOrEmpty
        }
    }

    It "Calls Get-InstallGlyphTypeface" {
        if (!(Test-Path $fontPath)) {
            Write-Host "$fontPath not found"
            return
        }

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
