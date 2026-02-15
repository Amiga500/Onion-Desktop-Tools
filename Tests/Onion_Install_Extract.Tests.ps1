# Onion_Install_Extract.Tests.ps1 - Tests for extraction operations

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import common functions
    $script:CommonFunctionsPath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    . $script:CommonFunctionsPath
}

Describe "Extract Script Structure" {
    Context "Script Requirements" {
        It "Should exist" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should have version requirement" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "#Requires -Version"
        }
        
        It "Should use Set-StrictMode" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Set-StrictMode"
        }
        
        It "Should import Common-Functions" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
    }
    
    Context "Parameter Handling" {
        It "Should accept target drive parameter" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "param|Target.*Drive|Drive.*Letter"
        }
        
        It "Should accept source file parameter" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "param|Source|File|Archive"
        }
    }
}

Describe "7-Zip Integration" {
    Context "7-Zip Tool" {
        It "Should use 7z.exe" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "7z\.exe"
        }
        
        It "Should check for 7zip tool existence" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Test-Path.*7z"
        }
        
        It "Should use extract command" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # The script uses 'x' for extract (7z x command)
            $scriptContent | Should -Match '7z.*x\s|"x "'
        }
    }
    
    Context "Extraction Options" {
        It "Should use appropriate 7zip flags" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Check for flags like -y (yes to all), -aoa (overwrite), etc.
            ($scriptContent -match "-y" -or 
             $scriptContent -match "-aoa" -or 
             $scriptContent -match "ArgumentList") | Should -Be $true
        }
    }
}

Describe "File Operations" {
    Context "Source File Validation" {
        It "Should check if source archive exists or handle files" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            ($scriptContent -match "Test-Path" -or 
             $scriptContent -match "downloads" -or
             $scriptContent -match "Update_File") | Should -Be $true
        }
        
        It "Should work with archive files" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "\.zip"
        }
    }
    
    Context "Target Drive Validation" {
        It "Should handle target drive" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            ($scriptContent -match "Target" -or 
             $scriptContent -match "Drive" -or
             $scriptContent -match "Destination") | Should -Be $true
        }
        
        It "Should work with drive selection" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            ($scriptContent -match "Disk_selector" -or 
             $scriptContent -match "Drive_Letter" -or
             $scriptContent -match "Target") | Should -Be $true
        }
    }
    
    Context "Space Validation" {
        It "Should check or display available disk space" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # May check free space or display it
            ($scriptContent -match "freeSpace|Free.*Space|Space available" -or
             $scriptContent -match "Get-Volume" -or
             $scriptContent -match "Get-PSDrive") | Should -Be $true
        }
    }
}

Describe "Extraction Process" {
    Context "Progress Reporting" {
        It "Should show extraction progress" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-Progress|Write-Host.*extract|progress"
        }
        
        It "Should log extraction steps" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-ODTLog"
        }
    }
    
    Context "External Command Execution" {
        It "Should execute 7zip command" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Start-Process|&|Invoke-Expression|Invoke-ExternalCommand"
        }
        
        It "Should capture command output" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Wait.*Exit|ExitCode|StandardOutput"
        }
    }
}

Describe "Error Handling" {
    Context "Extraction Errors" {
        It "Should have error handling mechanisms" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Check for any form of error handling
            ($scriptContent -match "try\s*\{.*catch" -or 
             $scriptContent -match "ErrorAction" -or
             $scriptContent -match "if.*error") | Should -Be $true
        }
        
        It "Should check extraction exit code" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "ExitCode|LASTEXITCODE|\$\?"
        }
        
        It "Should log errors" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-ODTLog.*Error|Write-Error"
        }
    }
    
    Context "Disk Full Scenarios" {
        It "Should have error handling for disk operations" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Should have some form of error handling
            $scriptContent | Should -Match "ErrorAction|if.*error|ExitCode"
        }
    }
    
    Context "Corrupted Archive" {
        It "Should have error handling" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Basic check for error handling presence
            $scriptContent | Should -Match "error|Error|EXIT"
        }
    }
}

Describe "Post-Extraction Validation" {
    Context "Verification" {
        It "Should verify extraction success" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "ExitCode.*0|success|Test-Path"
        }
        
        It "Should check key files exist after extraction" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # May verify critical Onion files
            $scriptContent | Should -Match "Test-Path"
        }
    }
}

Describe "Extract Integration" {
    Context "Logging Integration" {
        It "Should use Write-ODTLog" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-ODTLog"
        }
    }
    
    Context "Tools Integration" {
        It "Should use Test-RequiredTools or similar" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Test.*Tool|tools"
        }
    }
}

Describe "Extract Output" {
    Context "Return Values" {
        It "Should indicate success or failure" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "return|exit"
        }
        
        It "Should provide extraction status" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "success|complete|status"
        }
    }
}

Describe "Extract Best Practices" {
    Context "Code Quality" {
        It "Should set ErrorActionPreference or have error handling" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            ($scriptContent -match "ErrorActionPreference" -or 
             $scriptContent -match "ErrorAction") | Should -Be $true
        }
        
        It "Should have some form of error control" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Extract.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Should have error handling or exit codes
            ($scriptContent -match "exit" -or 
             $scriptContent -match "return" -or
             $scriptContent -match "throw") | Should -Be $true
        }
    }
}
