cd "您要測試Tests.ps1目錄"
$config = New-PesterConfiguration -Hashtable @{
    Run = @{
        Path = @("./my.Tests.ps1") # 置換成您的測試檔案
        ExcludePath = @()
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
        Enabled = $true # 會顯示覆蓋率
    }
    TestResult = @{
        OutputPath = ".\Pester-Test.xml"
        OutputFormat = "NUnitXml"
        OutputEncoding = 'UTF8'
        Enabled = $false # 可以不需要
    }
 }
Invoke-Pester -Configuration $config
