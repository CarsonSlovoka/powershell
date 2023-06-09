# https://pester-docs.netlify.app/docs/commands/New-PesterConfiguration
# Should: https://pester-docs.netlify.app/docs/commands/Should#begreaterthan
$runPath = @(
    "..\src\auth",
    "..\src\calendar",
    "..\src\os"
)

if ($PSVersionTable.PSVersion.Major -ge 6) {
    $runPath += @(
        "..\src\font"
    )
}

@{
	Run = @{
		# Path = @("..\src") # 只要有psd1都會納入，使用ExcludePath沒辦法排除，所以只能猜開寫
		Path = $runPath
		ExcludePath = @()
		# Filter used to identify test files.
		TestExtension = '.Tests.ps1'
	}
	Should = @{
		ErrorAction = 'Continue'
	}
	CodeCoverage = @{
		OutputFormat = 'JaCoCo'
		OutputEncoding = 'UTF8'
		OutputPath = ".\Pester-Coverage.xml"
		CoveragePercentTarget = 75 # default 75%
		Enabled = $true
	}
	TestResult = @{
		OutputPath = ".\Pester-Test.xml"
		OutputFormat = "NUnitXml"
		OutputEncoding = 'UTF8'
		Enabled = $true
	}
}
