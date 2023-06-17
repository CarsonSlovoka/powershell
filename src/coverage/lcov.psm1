function Convert-LCovToHtml {
    <#
    .Synopsis
        To help you generate an HTML to see the coverage
    .Description
        Before you run this command, you may need to install `perl.exe`
        run `choco install lcov` to help you.
    .Parameter outputDir
        for example: coverage/html
    .Parameter genHtmlConfigPath
        filepath of genhtml. for example: myGenhtml.perl
        The file content can refer to this link: https://github.com/linux-test-project/lcov/blob/521e31949b5571d9093e9e85462cb137dded05b4/bin/genhtml#L1-L10890
    .Parameter openHTML
        Open the browser to see the generated  result.
    .Example
        Convert-LCovToHtml my.lcov myOutDir
        Convert-LCovToHtml my.lcov coverage/html
        Convert-LCovToHtml my.lcov coverage/html -openHTML $false
    .Example
        Convert-LCovToHtml ./coverage/coverage.lcov ./coverage/html -genHtmlConfigPath myGenhtml.perl -Verbose
    .Link
        genhtml:
        https://github.com/linux-test-project/lcov/blob/521e31949b5571d9093e9e85462cb137dded05b4/bin/genhtml#L1-L10890
    .Link
        https://stackoverflow.com/q/62184806/9935654
    .Link
        https://fredgrott.medium.com/lcov-on-windows-7c58dda07080
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$inputLcov,
        [Parameter(Mandatory)]
        [string]$outputDir,
        [Parameter()]
        [string]$genHtmlConfigPath = "",
        [Parameter()]
        [bool]$openHTML=$true
    )
    $o = @{
       Err = $null
    }

    if (
        ($genHtmlConfigPath -eq "") -or
        (!(Test-Path $genHtmlConfigPath)) # path not exists
    ) {
        Write-Verbose "Try using the genhtml found in the system path as a replacement for it."
        $genHtml = Get-Command genhtml -ErrorAction SilentlyContinue # This is a config file; you can open and edit it to meet your style.
        $genHtmlConfigPath = $genHtml.Path
        Write-Verbose "genhtml: $genHtmlConfigPath" # for example: %ProgramData%\chocolatey\lib\lcov\tools\bin\genhtml
    }

    $perlExe = Get-Command perl -ErrorAction SilentlyContinue
    if (($genHtmlConfigPath -eq $null) -or ($perlExe -eq $null)) {
        Write-Host '[FileNotFoundError]: {genhtml, perl.exe}' -ForegroundColor Red
        Write-Host 'Please use command:' -NoNewLine
        Write-Host 'choco install lcov' -ForegroundColor Cyan -NoNewLine
        Write-Host 'to install'
        $o.Err = "FileNotFoundError"
        return
    }

    # make sure the output dir exists
    New-Item $outputDir -ItemType Directory -ErrorAction SilentlyContinue
    if (!(Test-Path $outputDir)) {
        # We will attempt to create the directory for you, but the creation will fail if your path is invalid.
        Write-Host "[OutputDirNotExists] $outputDir" -ForegroundColor Red
        $o.Err = "OutputDirNotExists"
        return $o
    }

    # perl.exe myGenhtml.perl my.lcov -o coverage/html
    Invoke-Expression "$($perlExe.Path) $genHtmlConfigPath $inputLcov -o $outputDir"

    if ($openHTML) {
        Start-Process (Join-Path $outputDir "index.html")
    }
    return $o
}
