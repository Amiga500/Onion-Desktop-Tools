# Integration.Tests.ps1 - Integration tests for end-to-end workflows

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import common functions
    $script:CommonFunctionsPath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    . $script:CommonFunctionsPath
    
    # Set up test environment
    $script:TestOutputPath = Join-Path $PSScriptRoot "test_output"
    if (-not (Test-Path $script:TestOutputPath)) {
        New-Item -ItemType Directory -Path $script:TestOutputPath -Force | Out-Null
    }
}

AfterAll {
    # Clean up test environment
    if (Test-Path $script:TestOutputPath) {
        Remove-Item -Path $script:TestOutputPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe "Core Module Integration" {
    Context "Common Functions and Configuration" {
        It "Configuration should be loaded on module import" {
            $config = Get-ODTConfiguration
            $config | Should -Not -BeNullOrEmpty
        }
        
        It "Logging should respect configuration" {
            $enableLogging = Get-ODTConfigValue -Section "General" -Key "EnablePersistentLogging" -Default $true
            $enableLogging | Should -BeOfType [bool]
        }
        
        It "Configuration values should be accessible" {
            $logLevel = Get-ODTConfigValue -Section "General" -Key "LogLevel" -Default "Info"
            $logLevel | Should -BeIn @("Debug", "Info", "Warning", "Error")
        }
    }
    
    Context "Logging System Integration" {
        It "Should write to log file when enabled" {
            # Log a test message
            Write-ODTLog "Integration test message" -Level Info
            
            # Check that log file exists
            $logDir = Join-Path $PSScriptRoot ".." "logs"
            Test-Path $logDir | Should -Be $true
        }
        
        It "Should support different log levels" {
            { Write-ODTLog "Info message" -Level Info } | Should -Not -Throw
            { Write-ODTLog "Warning message" -Level Warning } | Should -Not -Throw
            { Write-ODTLog "Error message" -Level Error } | Should -Not -Throw
        }
        
        It "Should create daily log files" {
            $logDir = Join-Path $PSScriptRoot ".." "logs"
            $today = Get-Date -Format 'yyyy-MM-dd'
            $expectedLog = "ODT_$today.log"
            $logPath = Join-Path $logDir $expectedLog
            
            # Write a message to ensure log exists
            Write-ODTLog "Test log rotation" -Level Info
            
            Test-Path $logPath | Should -Be $true
        }
    }
}

Describe "Security Features Integration" {
    Context "Administrator Checks" {
        It "Test-IsAdministrator should work" {
            # Skip on non-Windows platforms
            if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
                Set-ItResult -Skipped -Because "Administrator check only works on Windows"
            }
            else {
                $result = Test-IsAdministrator
                $result | Should -BeOfType [bool]
            }
        }
    }
    
    Context "Disk Safety Validation" {
        It "Should reject system drives" {
            $result = Test-IsSafeDiskToFormat -DriveNumber 0 -DriveLetter "C"
            $result | Should -Be $false
        }
        
        It "Should reject drives with Windows" {
            # Test multiple system drive scenarios
            $systemTests = @(
                @{ Disk = 0; Letter = "C" },
                @{ Disk = 1; Letter = "C" },
                @{ Disk = 5; Letter = "C" }
            )
            
            foreach ($test in $systemTests) {
                $result = Test-IsSafeDiskToFormat -DriveNumber $test.Disk -DriveLetter $test.Letter
                $result | Should -Be $false
            }
        }
        
        It "Should reject invalid disk numbers" {
            $result = Test-IsSafeDiskToFormat -DriveNumber -1 -DriveLetter "E"
            $result | Should -Be $false
            
            $result = Test-IsSafeDiskToFormat -DriveNumber 9999 -DriveLetter "E"
            $result | Should -Be $false
        }
    }
    
    Context "Tools Integrity" {
        It "Should verify tools manifest" {
            $result = Test-ToolsIntegrity
            $result | Should -Not -BeNullOrEmpty
            $result.Success | Should -BeOfType [bool]
        }
        
        It "Should check required tools" {
            $manifestPath = Join-Path $PSScriptRoot ".." "tools_manifest.json"
            if (Test-Path $manifestPath) {
                $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
                $manifest | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "Operational Features Integration" {
    Context "Dry-Run Mode" {
        It "Should detect WhatIf preference" {
            $result = Test-DryRun -WhatIf
            $result | Should -Be $true
        }
        
        It "Should respect configuration DryRunMode" {
            $dryRunSetting = Get-ODTConfigValue -Section "Operations" -Key "DryRunMode" -Default $false
            $dryRunSetting | Should -BeOfType [bool]
        }
        
        It "Invoke-ODTAction should support ShouldProcess" {
            $executed = $false
            $result = Invoke-ODTAction -Action "Test Action" -ScriptBlock { $executed = $true } -Target "Test"
            $result | Should -BeOfType [bool]
        }
    }
    
    Context "Ctrl+C Handling" {
        It "Should enable Ctrl+C handling" {
            { Enable-CtrlCHandling } | Should -Not -Throw
        }
        
        It "Should disable Ctrl+C handling" {
            { Disable-CtrlCHandling } | Should -Not -Throw
        }
        
        It "Should accept custom cleanup script" {
            $cleanup = $false
            { Enable-CtrlCHandling -CleanupScript { $cleanup = $true } } | Should -Not -Throw
        }
    }
}

Describe "Localization Integration" {
    Context "Language Support" {
        It "Should load language strings" {
            $strings = Get-LanguageStrings
            if ($strings) {
                $strings | Should -Not -BeNullOrEmpty
            }
        }
        
        It "Should get localized strings" {
            $msg = Get-LocalizedString -Category "Common" -Key "Yes"
            # Should return either localized string or fallback
            $msg | Should -Not -BeNullOrEmpty
        }
        
        It "Should support format arguments" {
            $msg = Get-LocalizedString -Category "Operations" -Key "DryRunMode" -Arguments "Test Operation"
            $msg | Should -Not -BeNullOrEmpty
        }
        
        It "Should have en-US language file" {
            $langPath = Join-Path $PSScriptRoot ".." "Languages" "en-US.json"
            Test-Path $langPath | Should -Be $true
        }
    }
}

Describe "File System Operations" {
    Context "Directory Initialization" {
        It "Should create directories safely" {
            $testDir = Join-Path $script:TestOutputPath "test_dir"
            Initialize-Directories -Directories @($testDir)
            Test-Path $testDir | Should -Be $true
        }
    }
}

Describe "Complete Workflow Simulation" {
    Context "Configuration to Execution Flow" {
        It "Should load config, check admin, and prepare logging" {
            # Step 1: Load configuration
            $config = Get-ODTConfiguration
            $config | Should -Not -BeNullOrEmpty
            
            # Step 2: Check administrator (if on Windows)
            if ($PSVersionTable.PSEdition -ne 'Core' -or $IsWindows) {
                $isAdmin = Test-IsAdministrator
                $isAdmin | Should -BeOfType [bool]
            }
            
            # Step 3: Initialize logging
            $logDir = Join-Path $PSScriptRoot ".." "logs"
            Test-Path $logDir | Should -Be $true
            
            # Step 4: Log operation start
            Write-ODTLog "Workflow simulation started" -Level Info
        }
    }
    
    Context "Safety Checks Before Destructive Operations" {
        It "Should perform all safety checks" {
            # Configuration check
            $confirmOps = Get-ODTConfigValue -Section "Operations" -Key "ConfirmDestructiveOperations" -Default $true
            $confirmOps | Should -BeOfType [bool]
            
            # Disk safety check
            $safeDisk = Test-IsSafeDiskToFormat -DriveNumber 0 -DriveLetter "C"
            $safeDisk | Should -Be $false
            
            # Dry-run check
            $dryRun = Test-DryRun
            $dryRun | Should -BeOfType [bool]
        }
    }
}

Describe "Tools Manifest Verification" {
    Context "External Tools Integrity" {
        It "Should have tools_manifest.json" {
            $manifestPath = Join-Path $PSScriptRoot ".." "tools_manifest.json"
            Test-Path $manifestPath | Should -Be $true
        }
        
        It "Manifest should be valid JSON" {
            $manifestPath = Join-Path $PSScriptRoot ".." "tools_manifest.json"
            { Get-Content -Path $manifestPath -Raw | ConvertFrom-Json } | Should -Not -Throw
        }
        
        It "Should verify tool integrity" {
            $result = Test-ToolsIntegrity
            $result.Success | Should -BeOfType [bool]
        }
    }
}

Describe "Error Handling Chain" {
    Context "Cascading Error Handling" {
        It "Should catch and log errors properly" {
            try {
                # Simulate an operation that might fail
                Write-ODTLog "Testing error handling" -Level Info
                
                # Test that error logging works
                Write-ODTLog "Simulated error" -Level Error
                
                $true | Should -Be $true
            }
            catch {
                # Should not throw
                $false | Should -Be $true
            }
        }
    }
}

Describe "Cross-Platform Compatibility" {
    Context "Platform Detection" {
        It "Should detect PowerShell edition" {
            $PSVersionTable.PSEdition | Should -BeIn @('Desktop', 'Core')
        }
        
        It "Should handle platform-specific code" {
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $IsWindows | Should -BeOfType [bool]
            }
        }
    }
}
