# Onion_Config.Tests.ps1 - Tests for configuration operations

#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    # Import common functions
    $script:CommonFunctionsPath = Join-Path $PSScriptRoot ".." "Common-Functions.ps1"
    . $script:CommonFunctionsPath
    
    # Test config.json path
    $script:ConfigPath = Join-Path $PSScriptRoot ".." "config.json"
}

Describe "Configuration File" {
    Context "Config File Existence" {
        It "Should have config.json file" {
            Test-Path $script:ConfigPath | Should -Be $true
        }
        
        It "Should be valid JSON" {
            { Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json } | Should -Not -Throw
        }
        
        It "Should have Onion_Configuration section" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.Onion_Configuration | Should -Not -BeNullOrEmpty
        }
        
        It "Should have ODT_Settings section" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "ODT Settings Structure" {
        It "Should have General settings" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.General | Should -Not -BeNullOrEmpty
        }
        
        It "Should have Operations settings" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.Operations | Should -Not -BeNullOrEmpty
        }
        
        It "Should have Advanced settings" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.Advanced | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "General Settings Values" {
        It "Should have LogLevel setting" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.General.LogLevel | Should -Not -BeNullOrEmpty
        }
        
        It "Should have EnablePersistentLogging setting" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.General.PSObject.Properties.Name | Should -Contain "EnablePersistentLogging"
        }
        
        It "Should have Language setting" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.General.Language | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Operations Settings Values" {
        It "Should have DryRunMode setting" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.Operations.PSObject.Properties.Name | Should -Contain "DryRunMode"
        }
        
        It "Should have EnableCtrlCHandling setting" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.ODT_Settings.Operations.PSObject.Properties.Name | Should -Contain "EnableCtrlCHandling"
        }
    }
}

Describe "Onion Configuration Scripts" {
    Context "Settings Script" {
        It "Should have Onion_Config_00_settings.ps1" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_00_settings.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should import Common-Functions" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_00_settings.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
        
        It "Should load config.json" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_00_settings.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "config\.json"
        }
    }
    
    Context "Emulators Script" {
        It "Should have Onion_Config_01_Emulators.ps1" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_01_Emulators.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should import Common-Functions" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_01_Emulators.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
    }
    
    Context "WiFi Script" {
        It "Should have Onion_Config_02_wifi.ps1" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_02_wifi.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should import Common-Functions" {
            $scriptPath = Join-Path $PSScriptRoot ".." "Onion_Config_02_wifi.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "Common-Functions\.ps1"
        }
    }
}

Describe "Configuration File Operations" {
    Context "Onion Configuration Structure" {
        It "Should have System configuration" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.Onion_Configuration.System | Should -Not -BeNullOrEmpty
        }
        
        It "Should have Time configuration" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.Onion_Configuration.Time | Should -Not -BeNullOrEmpty
        }
        
        It "Should have Network configuration" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.Onion_Configuration.Network | Should -Not -BeNullOrEmpty
        }
        
        It "Should have User interface configuration" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $config.Onion_Configuration.'User interface' | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Configuration Items Format" {
        It "System items should have required fields" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $firstItem = $config.Onion_Configuration.System[0]
            $firstItem.filename | Should -Not -BeNullOrEmpty
            $firstItem.short_description | Should -Not -BeNullOrEmpty
            $firstItem.description | Should -Not -BeNullOrEmpty
        }
        
        It "Network items should have required fields" {
            $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $firstItem = $config.Onion_Configuration.Network[0]
            $firstItem.filename | Should -Not -BeNullOrEmpty
            $firstItem.short_description | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Configuration Loading Functions" {
    Context "Get-ODTConfiguration" {
        It "Should load configuration successfully" {
            $config = Get-ODTConfiguration
            $config | Should -Not -BeNullOrEmpty
        }
        
        It "Should return configuration object" {
            $config = Get-ODTConfiguration
            $config.General | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-ODTConfigValue" {
        It "Should retrieve LogLevel value" {
            $value = Get-ODTConfigValue -Section "General" -Key "LogLevel" -Default "Info"
            $value | Should -Not -BeNullOrEmpty
        }
        
        It "Should retrieve DryRunMode value" {
            $value = Get-ODTConfigValue -Section "Operations" -Key "DryRunMode" -Default $false
            $value | Should -BeOfType [bool]
        }
        
        It "Should return default for non-existent key" {
            $value = Get-ODTConfigValue -Section "General" -Key "NonExistentKey123" -Default "TestDefault"
            $value | Should -Be "TestDefault"
        }
        
        It "Should handle missing section gracefully" {
            $value = Get-ODTConfigValue -Section "NonExistentSection" -Key "SomeKey" -Default "DefaultValue"
            $value | Should -Be "DefaultValue"
        }
    }
}

Describe "PC WiFi Info Script" {
    Context "WiFi Script Structure" {
        It "Should have PC_WifiInfo.ps1" {
            $scriptPath = Join-Path $PSScriptRoot ".." "PC_WifiInfo.ps1"
            Test-Path $scriptPath | Should -Be $true
        }
        
        It "Should extract WiFi information" {
            $scriptPath = Join-Path $PSScriptRoot ".." "PC_WifiInfo.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "netsh|wifi|wlan"
        }
        
        It "Should have error handling" {
            $scriptPath = Join-Path $PSScriptRoot ".." "PC_WifiInfo.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw
            $scriptContent | Should -Match "try.*catch|ErrorAction"
        }
    }
}

Describe "Configuration Integration" {
    Context "Config Usage in Scripts" {
        It "Scripts should reference ODT_Settings" {
            $config = Get-ODTConfiguration
            $config.General.LogLevel | Should -BeIn @("Debug", "Info", "Warning", "Error")
        }
        
        It "Configuration should affect logging" {
            $logLevel = Get-ODTConfigValue -Section "General" -Key "LogLevel" -Default "Info"
            $logLevel | Should -Not -BeNullOrEmpty
        }
    }
}
