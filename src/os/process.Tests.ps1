Describe "os.process.psm1" {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'os.psd1')
    }

    It "Calls Stop-ProcessByName" {
        InModuleScope os {
            # $runSpace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
            $typeTable = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()
            $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateOutOfProcessRunspace($typeTable)
            $runSpace.Open()
            # Get-Runspace
            $powerShell = [PowerShell]::Create()
            $powerShell.Runspace = $runSpace
            $myPID = $PowerShell.AddScript("`$PID").Invoke()
            Stop-ProcessByName (Get-process -Id $myPID).Name -WhatIf
            $powerShell.Dispose()
            $runSpace.Dispose()
        }
    }
}
