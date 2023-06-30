# https://pester-docs.netlify.app/docs/commands/New-PesterConfiguration
# Should: https://pester-docs.netlify.app/docs/commands/Should#begreaterthan
$runPath = @(
    "..\src\auth",
    "..\src\calendar",
    "..\src\os",
    "..\src\font\info.Tests.ps1",
    "..\src\forms"
)

$quicklyMode = $false

if ($PSVersionTable.PSVersion.Major -ge 6) {
    $runPath += @(
        "..\src\font"
    )
}

# $PSVersionTable.PSVersion.ToString().Substring(0, 3) -eq "6.2"
if (($PSVersionTable.PSVersion.Major -ge 6) -and ($PSVersionTable.PSVersion.Minor -ge 2)) {
    $runPath += @(
        "..\src\encoding"
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
		Enabled = !$quicklyMode
	}
	TestResult = @{
		OutputPath = ".\Pester-Test.xml"
		OutputFormat = "NUnitXml"
		OutputEncoding = 'UTF8'
		Enabled = !$quicklyMode
	}
}
