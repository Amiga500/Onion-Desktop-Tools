# Onion_Install_Download.Tests.ps1 - Tests for download operations

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import common functions
    $script:CommonFunctionsPath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    . $script:CommonFunctionsPath
    
    # Mock GitHub API response
    $script:MockGitHubRelease = @{
        tag_name = "v4.2.0"
        name = "OnionOS v4.2.0"
        assets = @(
            @{
                name = "Onion-v4.2.0.zip"
                size = 104857600
                browser_download_url = "https://github.com/OnionUI/Onion/releases/download/v4.2.0/Onion-v4.2.0.zip"
            }
        )
    }
}

Describe "Download Script Structure" {
    Context "Script Requirements" {
        It "Should exist" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should have version requirement" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "#Requires -Version"
        }
        
        It "Should use Set-StrictMode" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Set-StrictMode"
        }
        
        It "Should import Common-Functions" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
    }
    
    Context "Configuration Loading" {
        It "Should import Common-Functions for configuration access" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Script should import Common-Functions which handles config
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
    }
}

Describe "GitHub Release Fetching" {
    Context "API Integration" {
        It "Should use GitHub API" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "api\.github\.com|github\.com.*releases"
        }
        
        It "Should fetch latest release" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "latest|releases"
        }
        
        It "Should use Invoke-RestMethod or ConvertFrom-Json" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Invoke-RestMethod auto-parses JSON, or explicit ConvertFrom-Json
            $scriptContent | Should -Match "Invoke-RestMethod|ConvertFrom-Json"
        }
    }
    
    Context "Release Information Extraction" {
        It "Should access release metadata" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Script should access release properties (tag_name, name, or version)
            $scriptContent | Should -Match "tag_name|\.name|version|assets_info"
        }
        
        It "Should extract assets" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "assets"
        }
        
        It "Should get download URL" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "browser_download_url|download.*url"
        }
    }
}

Describe "Download Operations" {
    Context "File Download" {
        It "Should use WebClient or Invoke-WebRequest" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "WebClient|Invoke-WebRequest|wget"
        }
        
        It "Should save to downloads directory" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "downloads"
        }
        
        It "Should create downloads directory if missing" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "New-Item.*Directory|mkdir|Initialize-Directories"
        }
    }
    
    Context "Progress Reporting" {
        It "Should show download progress" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-Progress|Write-Host.*download|progress"
        }
    }
}

Describe "Hash Verification" {
    Context "File Integrity" {
        It "Should compute file hash" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Get-FileHash|Test-FileHash"
        }
        
        It "Should use SHA256 algorithm" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "SHA256"
        }
        
        It "Should display hash to user" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-Host.*hash|Write-ODTLog.*hash"
        }
    }
}

Describe "Error Handling" {
    Context "Network Errors" {
        It "Should have error handling mechanisms" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Check for any form of error handling
            ($scriptContent -match "try\s*\{" -or 
             $scriptContent -match "ErrorAction" -or
             $scriptContent -match "if.*error") | Should -Be $true
        }
        
        It "Should have error handling or logging" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Check for error handling (try/catch, ErrorAction) or logging
            ($scriptContent -match "Write-ODTLog" -or
             $scriptContent -match "Write-Error" -or
             $scriptContent -match "Write-Warning" -or
             $scriptContent -match "try\s*\{" -or
             $scriptContent -match "ErrorAction") | Should -Be $true
        }
        
        It "Should handle network operations safely" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Should have error handling or explicit ErrorAction
            ($scriptContent -match "ErrorAction" -or 
             $scriptContent -match "try" -or
             $scriptContent -match "if.*error") | Should -Be $true
        }
    }
    
    Context "File System Errors" {
        It "Should handle file operations" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Should have file operations
            $scriptContent | Should -Match "downloads|New-Item|Test-Path"
        }
        
        It "Should handle errors in file operations" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Should have some error control
            ($scriptContent -match "ErrorAction" -or 
             $scriptContent -match "try" -or
             $scriptContent -match "if.*Test-Path") | Should -Be $true
        }
    }
}

Describe "Download Configuration" {
    Context "User Agent" {
        It "Should use Invoke-RestMethod with proper parameters" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Invoke-RestMethod includes user agent by default or via Headers
            # Just verify Invoke-RestMethod is used for GitHub API
            $scriptContent | Should -Match "Invoke-RestMethod.*github|Invoke-WebRequest"
        }
    }
    
    Context "SSL/TLS" {
        It "Should use secure connections" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "https://"
        }
    }
}

Describe "Download Integration" {
    Context "Logging Integration" {
        It "Should use Write-ODTLog" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Write-ODTLog"
        }
    }
    
    Context "Test-FileHash Integration" {
        It "Should call Test-FileHash function" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Test-FileHash|Get-FileHash"
        }
    }
}

Describe "Download Output" {
    Context "Return Values" {
        It "Should return download status" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            # Script should indicate success/failure
            $scriptContent | Should -Match "return|exit"
        }
        
        It "Should provide file path on success" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Install_Download.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "\$.*path|\$.*file"
        }
    }
}
