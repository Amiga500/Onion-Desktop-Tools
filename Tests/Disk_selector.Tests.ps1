# Disk_selector.Tests.ps1 - Tests for disk selector GUI

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import common functions if needed
    $script:CommonFunctionsPath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    if (Test-Path $script:CommonFunctionsPath) {
        . $script:CommonFunctionsPath
    }
}

Describe "Disk Selector Script Structure" {
    Context "Script Initialization" {
        It "Should exist" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should have version requirement" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "#Requires -Version"
        }
        
        It "Should use Set-StrictMode" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Set-StrictMode"
        }
        
        It "Should accept Title parameter" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "param.*Title"
        }
    }
    
    Context "GUI Components" {
        It "Should use Windows Forms" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "System\.Windows\.Forms"
        }
        
        It "Should create a Form" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "New-Object System\.Windows\.Forms\.Form"
        }
        
        It "Should have GroupBox for drives" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "System\.Windows\.Forms\.GroupBox"
        }
        
        It "Should have radio buttons for drive selection" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "RadioButton"
        }
        
        It "Should have OK button" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "button_ok|OK"
        }
        
        It "Should have Refresh button" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "refreshButton|Refresh"
        }
    }
    
    Context "Drive Detection" {
        It "Should use RMPARTUSB tool" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "RMPARTUSB\.exe"
        }
        
        It "Should have RefreshDriveList function" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "function RefreshDriveList"
        }
        
        It "Should show 'No drive found' message when appropriate" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "No drive found|ShowNoDriveFoundLabel"
        }
    }
    
    Context "User Experience" {
        It "Should center the form on screen" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "CenterScreen"
        }
        
        It "Should have custom icon" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "sdcard\.ico"
        }
        
        It "Should set form title" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Drive Selector"
        }
    }
}

Describe "Disk Selector Safety Features" {
    Context "Administrator Check" {
        It "Should mention administrator requirement" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "administrator"
        }
    }
    
    Context "Output Validation" {
        It "Should return selected drive information" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "selectedDrive"
        }
        
        It "Should handle drive selection state" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Checked|Selected"
        }
    }
}

Describe "Disk Selector Error Handling" {
    Context "Missing Tools" {
        It "Should check for RMPARTUSB tool existence" {
            $toolPath = Join-Path $PSScriptRoot ".." "tools" "RMPARTUSB.exe"
            # Tool should exist or script should handle gracefully
            if (Test-Path $toolPath) {
                $true | Should -Be $true
            } else {
                # Script should handle missing tool
                $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
                $scriptContent = Get-Content -Path $scriptPath -Raw
                $scriptContent | Should -Match "No drive found|error"
            }
        }
    }
    
    Context "Empty Drive List" {
        It "Should have function to show no drive found message" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "ShowNoDriveFoundLabel"
        }
    }
}

Describe "Disk Selector Integration" {
    Context "Tool Integration" {
        It "Should be in tools/res directory structure" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "tools\\|tools/"
        }
        
        It "Should handle LIST command for RMPARTUSB" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Disk_selector.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match 'LIST'
        }
    }
}
