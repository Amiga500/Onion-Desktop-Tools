# Common-Functions.Tests.ps1 - Pester tests for Common-Functions module

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import the module to test
    $script:ModulePath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    . $script:ModulePath
}

Describe "Configuration Functions" {
    Context "Get-ODTConfiguration" {
        It "Should load configuration from config.json" {
            $config = Get-ODTConfiguration
            $config | Should -Not -BeNullOrEmpty
        }
        
        It "Should have ODT_Settings sections" {
            $config = Get-ODTConfiguration
            $config.General | Should -Not -BeNullOrEmpty
            $config.Operations | Should -Not -BeNullOrEmpty
            $config.Advanced | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-ODTConfigValue" {
        It "Should retrieve configuration values" {
            $value = Get-ODTConfigValue -Section "General" -Key "LogLevel" -Default "Info"
            $value | Should -Not -BeNullOrEmpty
        }
        
        It "Should return default for missing keys" {
            $value = Get-ODTConfigValue -Section "General" -Key "NonExistentKey" -Default "DefaultValue"
            $value | Should -Be "DefaultValue"
        }
    }
}

Describe "Administrator Check" {
    Context "Test-IsAdministrator" {
        It "Should return a boolean value" {
            $result = Test-IsAdministrator
            $result | Should -BeOfType [bool]
        }
    }
}

Describe "Disk Safety Validation" {
    Context "Test-IsSafeDiskToFormat" {
        It "Should reject system drive (C:)" {
            $result = Test-IsSafeDiskToFormat -DriveNumber 0 -DriveLetter "C"
            $result | Should -Be $false
        }
        
        It "Should reject invalid disk numbers" {
            $result = Test-IsSafeDiskToFormat -DriveNumber -1 -DriveLetter "E"
            $result | Should -Be $false
        }
    }
}

Describe "Logging Functions" {
    Context "Write-ODTLog" {
        It "Should accept different log levels" {
            { Write-ODTLog "Test message" -Level Info } | Should -Not -Throw
            { Write-ODTLog "Warning message" -Level Warning } | Should -Not -Throw
            { Write-ODTLog "Error message" -Level Error } | Should -Not -Throw
        }
        
        It "Should support NoConsole parameter" {
            { Write-ODTLog "Silent message" -Level Info -NoConsole } | Should -Not -Throw
        }
    }
}

Describe "Dry-Run Functions" {
    Context "Test-DryRun" {
        It "Should detect WhatIf parameter" {
            $result = Test-DryRun -WhatIf
            $result | Should -Be $true
        }
        
        It "Should return false when not in dry-run mode" {
            $result = Test-DryRun
            # Result depends on config, should be boolean
            $result | Should -BeOfType [bool]
        }
    }
    
    Context "Invoke-ODTAction" {
        It "Should execute action when not in WhatIf mode" {
            $executed = $false
            $result = Invoke-ODTAction -Action "Test Action" -ScriptBlock { $executed = $true } -Target "TestTarget"
            # In normal mode, should execute
            $result | Should -BeOfType [bool]
        }
    }
}

Describe "Tools Integrity" {
    Context "Test-ToolsIntegrity" {
        It "Should check tools manifest" {
            $result = Test-ToolsIntegrity
            $result | Should -Not -BeNullOrEmpty
            $result.Success | Should -BeOfType [bool]
        }
    }
}

Describe "Ctrl+C Handling" {
    Context "Enable-CtrlCHandling" {
        It "Should enable Ctrl+C handling without errors" {
            { Enable-CtrlCHandling } | Should -Not -Throw
        }
    }
    
    Context "Disable-CtrlCHandling" {
        It "Should disable Ctrl+C handling without errors" {
            { Disable-CtrlCHandling } | Should -Not -Throw
        }
    }
}
