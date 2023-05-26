$pesterConfiguration = Get-Content (Join-Path $PSScriptRoot config.pester.ps1) -Raw
<#
可以直接這樣用，但我們想要讀外部檔案，使的github action也能共用此config
$pesterConfig = @{
	Run = @{
	}
}
$config = New-PesterConfiguration -Hashtable $pesterConfig
#>
$config = New-PesterConfiguration -Hashtable ($pesterConfiguration | Invoke-Expression)
Invoke-Pester -Configuration $config
