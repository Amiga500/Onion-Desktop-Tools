# Common-Functions.ps1 - Shared utility functions for Onion Desktop Tools
# Version: 1.2.0

#Requires -Version 5.1

Set-StrictMode -Version Latest

# Global error action preference for the module
$ErrorActionPreference = 'Stop'

# Global configuration
$script:ConfigPath = Join-Path $PSScriptRoot "config.json"
$script:ODTConfig = $null

# Global logging configuration
$script:LogDirectory = Join-Path $PSScriptRoot "logs"
$script:LogFileName = "ODT_$(Get-Date -Format 'yyyy-MM-dd').log"
$script:LogFilePath = Join-Path $script:LogDirectory $script:LogFileName
$script:EnableFileLogging = $true
$script:MaxLogSizeMB = 10
$script:MaxLogFiles = 30

<#
.SYNOPSIS
    Loads ODT configuration from config.json
.DESCRIPTION
    Reads and parses the configuration file, with fallback to defaults
.OUTPUTS
    PSCustomObject - Configuration object
#>
function Get-ODTConfiguration {
    [CmdletBinding()]
    param()
    
    try {
        if ($script:ODTConfig) {
            return $script:ODTConfig
        }
        
        if (Test-Path -Path $script:ConfigPath) {
            $configJson = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json
            $script:ODTConfig = $configJson.ODT_Settings
            
            # Update logging configuration from config
            if ($script:ODTConfig.General) {
                $script:EnableFileLogging = $script:ODTConfig.General.EnablePersistentLogging
                $script:MaxLogSizeMB = $script:ODTConfig.General.MaxLogSizeMB
                $script:MaxLogFiles = $script:ODTConfig.General.LogRetentionDays
            }
            
            return $script:ODTConfig
        }
        else {
            Write-Warning "Configuration file not found: $script:ConfigPath. Using defaults."
            return $null
        }
    }
    catch {
        Write-Warning "Failed to load configuration: $_. Using defaults."
        return $null
    }
}

<#
.SYNOPSIS
    Gets a specific configuration value
.PARAMETER Section
    Configuration section (General, Operations, Advanced)
.PARAMETER Key
    Configuration key name
.PARAMETER Default
    Default value if key not found
.OUTPUTS
    Configuration value or default
#>
function Get-ODTConfigValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Section,
        
        [Parameter(Mandatory = $true)]
        [string]$Key,
        
        [Parameter(Mandatory = $false)]
        $Default = $null
    )
    
    try {
        $config = Get-ODTConfiguration
        if ($config -and $config.$Section -and $config.$Section.$Key -ne $null) {
            return $config.$Section.$Key
        }
        return $Default
    }
    catch {
        return $Default
    }
}

<#
.SYNOPSIS
    Initializes the logging system
.DESCRIPTION
    Creates log directory, sets up log file, and performs log rotation
#>
function Initialize-Logging {
    [CmdletBinding()]
    param()
    
    try {
        # Create logs directory if it doesn't exist
        if (-not (Test-Path -Path $script:LogDirectory -PathType Container)) {
            New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
        }
        
        # Perform log rotation - keep only last N days
        $logFiles = Get-ChildItem -Path $script:LogDirectory -Filter "ODT_*.log" -ErrorAction SilentlyContinue
        if ($logFiles) {
            $oldLogs = $logFiles | Sort-Object LastWriteTime -Descending | Select-Object -Skip $script:MaxLogFiles
            foreach ($oldLog in $oldLogs) {
                try {
                    Remove-Item -Path $oldLog.FullName -Force -ErrorAction SilentlyContinue
                } catch {
                    # Silently ignore if can't delete old log
                }
            }
        }
        
        # Check current log size and rotate if needed
        if (Test-Path -Path $script:LogFilePath) {
            $logSize = (Get-Item -Path $script:LogFilePath).Length / 1MB
            if ($logSize -gt $script:MaxLogSizeMB) {
                $timestamp = Get-Date -Format 'HHmmss'
                $rotatedName = "ODT_$(Get-Date -Format 'yyyy-MM-dd')_$timestamp.log"
                $rotatedPath = Join-Path $script:LogDirectory $rotatedName
                Move-Item -Path $script:LogFilePath -Destination $rotatedPath -Force -ErrorAction SilentlyContinue
            }
        }
        
        # Write initialization marker
        if ($script:EnableFileLogging) {
            $initMsg = "`n" + ("=" * 80) + "`n"
            $initMsg += "Onion Desktop Tools - Session Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
            $initMsg += ("=" * 80) + "`n"
            Add-Content -Path $script:LogFilePath -Value $initMsg -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "Failed to initialize logging: $_"
        $script:EnableFileLogging = $false
    }
}

<#
.SYNOPSIS
    Validates that the current user has administrator privileges
.DESCRIPTION
    Checks if the current PowerShell session is running with administrator rights
.OUTPUTS
    Boolean - True if running as administrator, False otherwise
#>
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
    Validates that a disk number is safe to format (not a system disk)
.DESCRIPTION
    Performs multiple safety checks to ensure the disk is not:
    - The system disk (C:)
    - A disk containing Windows installation
    - A disk with critical system files
.PARAMETER DriveNumber
    The drive number to validate
.PARAMETER DriveLetter
    The drive letter to validate (optional, for additional checks)
.OUTPUTS
    Boolean - True if safe to format, False otherwise
.EXAMPLE
    Test-IsSafeDiskToFormat -DriveNumber 1 -DriveLetter "E"
#>
function Test-IsSafeDiskToFormat {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$DriveNumber,
        
        [Parameter(Mandatory = $false)]
        [string]$DriveLetter
    )
    
    try {
        # Check 1: Verify disk number is valid
        if ($DriveNumber -lt 0) {
            Write-Warning "Invalid disk number: $DriveNumber"
            return $false
        }
        
        # Check 2: Get system drive information
        $systemDrive = $env:SystemDrive
        if (-not $systemDrive) {
            $systemDrive = "C:"
        }
        
        # Check 3: If drive letter provided, ensure it's not the system drive
        if ($DriveLetter) {
            $normalizedLetter = $DriveLetter.TrimEnd(':')
            $normalizedSystemDrive = $systemDrive.TrimEnd(':')
            
            if ($normalizedLetter -eq $normalizedSystemDrive) {
                Write-Warning "Cannot format system drive: $DriveLetter"
                return $false
            }
            
            # Check 4: Look for Windows directory
            $windowsPath = "${DriveLetter}:\Windows"
            if (Test-Path -Path $windowsPath -PathType Container) {
                Write-Warning "Drive contains Windows installation: $DriveLetter"
                return $false
            }
            
            # Check 5: Look for Program Files
            $programFilesPath = "${DriveLetter}:\Program Files"
            if (Test-Path -Path $programFilesPath -PathType Container) {
                Write-Warning "Drive contains Program Files: $DriveLetter"
                return $false
            }
        }
        
        # Check 6: Get disk information using WMI
        try {
            $disk = Get-WmiObject -Class Win32_DiskDrive -Filter "Index = $DriveNumber" -ErrorAction Stop
            
            if ($disk) {
                # Check if disk is removable
                $mediaType = $disk.MediaType
                Write-Verbose "Disk $DriveNumber media type: $mediaType"
                
                # Additional safety: Check disk size (system disks are typically larger)
                $diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
                Write-Verbose "Disk $DriveNumber size: $diskSizeGB GB"
                
                # Warn if disk is very large (might be internal HDD)
                if ($diskSizeGB -gt 512) {
                    Write-Warning "Disk $DriveNumber is very large ($diskSizeGB GB). Verify it's an SD card."
                }
            }
        }
        catch {
            Write-Verbose "Could not retrieve WMI disk information: $_"
            # Continue with other checks
        }
        
        return $true
    }
    catch {
        Write-Error "Error validating disk safety: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Validates hash/checksum of a downloaded file
.DESCRIPTION
    Computes and verifies the hash of a file against an expected value.
    Can also verify against GitHub release asset if asset info provided.
.PARAMETER FilePath
    Path to the file to verify
.PARAMETER ExpectedHash
    Expected hash value (optional if AssetInfo provided)
.PARAMETER Algorithm
    Hash algorithm to use (default: SHA256)
.PARAMETER AssetInfo
    GitHub asset info object from API (contains size for verification)
.OUTPUTS
    PSCustomObject with verification results
#>
function Test-FileHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [string]$ExpectedHash,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('SHA256', 'SHA1', 'MD5')]
        [string]$Algorithm = 'SHA256',
        
        [Parameter(Mandatory = $false)]
        [PSCustomObject]$AssetInfo
    )
    
    $result = [PSCustomObject]@{
        Success = $false
        FileExists = $false
        SizeMatch = $false
        HashMatch = $false
        ActualHash = $null
        ExpectedHash = $ExpectedHash
        ActualSize = 0
        ExpectedSize = 0
        Message = ""
    }
    
    try {
        if (-not (Test-Path -Path $FilePath)) {
            $result.Message = "File not found: $FilePath"
            Write-ODTLog $result.Message -Level Warning
            return $result
        }
        
        $result.FileExists = $true
        $fileInfo = Get-Item -Path $FilePath
        $result.ActualSize = $fileInfo.Length
        
        # Check size if asset info provided
        if ($AssetInfo -and $AssetInfo.size) {
            $result.ExpectedSize = $AssetInfo.size
            if ($result.ActualSize -eq $result.ExpectedSize) {
                $result.SizeMatch = $true
                Write-ODTLog "File size matches expected: $($result.ActualSize) bytes" -Level Debug
            } else {
                $result.Message = "Size mismatch: expected $($result.ExpectedSize) bytes, got $($result.ActualSize) bytes"
                Write-ODTLog $result.Message -Level Warning
                return $result
            }
        }
        
        # Compute hash
        $result.ActualHash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm -ErrorAction Stop).Hash
        Write-ODTLog "Computed $Algorithm hash: $($result.ActualHash)" -Level Debug
        
        # Verify hash if expected hash provided
        if ($ExpectedHash) {
            $result.HashMatch = ($result.ActualHash -eq $ExpectedHash)
            
            if (-not $result.HashMatch) {
                $result.Message = "Hash mismatch: expected $ExpectedHash, got $($result.ActualHash)"
                Write-ODTLog $result.Message -Level Warning
                return $result
            } else {
                Write-ODTLog "Hash verification passed" -Level Info
            }
        }
        
        $result.Success = $result.FileExists -and ($result.SizeMatch -or -not $AssetInfo) -and ($result.HashMatch -or -not $ExpectedHash)
        $result.Message = if ($result.Success) { "File verification passed" } else { "Verification incomplete" }
        
        return $result
    }
    catch {
        $result.Message = "Error during file verification: $_"
        Write-ODTLog $result.Message -Level Error
        return $result
    }
}

<#
.SYNOPSIS
    Writes a log message to both console and log file
.DESCRIPTION
    Provides centralized logging with timestamps and levels, with automatic file logging
.PARAMETER Message
    The message to log
.PARAMETER Level
    Log level (Info, Warning, Error, Debug)
.PARAMETER LogFile
    Optional path to specific log file (overrides default)
.PARAMETER NoConsole
    If set, suppresses console output (file only)
#>
function Write-ODTLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [string]$LogFile,
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console unless suppressed
    if (-not $NoConsole) {
        switch ($Level) {
            'Error' { Write-Host $logMessage -ForegroundColor Red }
            'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
            'Debug' { Write-Verbose $logMessage }
            default { Write-Host $logMessage }
        }
    }
    
    # Write to file
    $targetLogFile = if ($LogFile) { $LogFile } else { $script:LogFilePath }
    
    if ($script:EnableFileLogging -or $LogFile) {
        try {
            # Ensure log directory exists
            $logDir = Split-Path -Path $targetLogFile -Parent
            if ($logDir -and -not (Test-Path -Path $logDir -PathType Container)) {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }
            
            Add-Content -Path $targetLogFile -Value $logMessage -ErrorAction Stop
        }
        catch {
            if (-not $NoConsole) {
                Write-Warning "Failed to write to log file: $_"
            }
        }
    }
}

<#
.SYNOPSIS
    Safely invokes an external executable with error handling
.DESCRIPTION
    Wraps external executable calls with proper error handling and logging
.PARAMETER FilePath
    Path to the executable
.PARAMETER ArgumentList
    Arguments to pass to the executable
.PARAMETER WorkingDirectory
    Working directory for the process
.OUTPUTS
    PSCustomObject with ExitCode and Success properties
#>
function Invoke-ExternalCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [string]$ArgumentList,
        
        [Parameter(Mandatory = $false)]
        [string]$WorkingDirectory
    )
    
    try {
        Write-ODTLog "Executing: $FilePath $ArgumentList" -Level Debug
        
        $processParams = @{
            FilePath = $FilePath
            Wait = $true
            NoNewWindow = $true
            PassThru = $true
        }
        
        if ($ArgumentList) {
            $processParams['ArgumentList'] = $ArgumentList
        }
        
        if ($WorkingDirectory) {
            $processParams['WorkingDirectory'] = $WorkingDirectory
        }
        
        $process = Start-Process @processParams
        
        $result = [PSCustomObject]@{
            ExitCode = $process.ExitCode
            Success = ($process.ExitCode -eq 0)
        }
        
        if (-not $result.Success) {
            Write-ODTLog "Command failed with exit code: $($process.ExitCode)" -Level Warning
        }
        
        return $result
    }
    catch {
        Write-ODTLog "Error executing command: $_" -Level Error
        return [PSCustomObject]@{
            ExitCode = -1
            Success = $false
        }
    }
}

<#
.SYNOPSIS
    Validates that required external tools are available
.DESCRIPTION
    Checks for the presence of required external executables
.PARAMETER ToolsPath
    Path to the tools directory
.OUTPUTS
    Boolean - True if all required tools are present
#>
function Test-RequiredTools {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ToolsPath = ".\tools"
    )
    
    $requiredTools = @(
        '7z.exe',
        'RMPARTUSB.exe',
        'wget.exe'
    )
    
    $allPresent = $true
    
    foreach ($tool in $requiredTools) {
        $toolPath = Join-Path -Path $ToolsPath -ChildPath $tool
        if (-not (Test-Path -Path $toolPath)) {
            Write-Warning "Required tool not found: $tool"
            $allPresent = $false
        }
    }
    
    return $allPresent
}

<#
.SYNOPSIS
    Verifies tools against the manifest
.DESCRIPTION
    Checks tool integrity by comparing SHA256 hashes against tools_manifest.json
.PARAMETER ToolsPath
    Path to the tools directory
.PARAMETER ManifestPath
    Path to the tools manifest JSON file
.PARAMETER VerifyOptional
    If set, also verifies optional tools
.OUTPUTS
    PSCustomObject with verification results
#>
function Test-ToolsIntegrity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ToolsPath = ".\tools",
        
        [Parameter(Mandatory = $false)]
        [string]$ManifestPath = ".\tools_manifest.json",
        
        [Parameter(Mandatory = $false)]
        [switch]$VerifyOptional
    )
    
    $result = [PSCustomObject]@{
        Success = $true
        RequiredMissing = @()
        OptionalMissing = @()
        HashMismatches = @()
        VerifiedCount = 0
        TotalRequired = 0
    }
    
    try {
        if (-not (Test-Path -Path $ManifestPath)) {
            Write-ODTLog "Tools manifest not found: $ManifestPath" -Level Warning
            return $result
        }
        
        $manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
        Write-ODTLog "Verifying tools against manifest v$($manifest.manifest_version)" -Level Debug
        
        foreach ($tool in $manifest.tools) {
            # Skip optional tools unless requested
            if (-not $tool.required -and -not $VerifyOptional) {
                continue
            }
            
            if ($tool.required) {
                $result.TotalRequired++
            }
            
            # Handle tools in subdirectories (e.g., LockHunter/LockHunter32.exe)
            $toolPath = if ($tool.name -like "*/*") {
                Join-Path -Path $ToolsPath -ChildPath $tool.name
            } else {
                Join-Path -Path $ToolsPath -ChildPath $tool.name
            }
            
            # Check if tool exists
            if (-not (Test-Path -Path $toolPath)) {
                if ($tool.required) {
                    $result.RequiredMissing += $tool.name
                    $result.Success = $false
                    Write-ODTLog "Required tool missing: $($tool.name)" -Level Warning
                } else {
                    $result.OptionalMissing += $tool.name
                    Write-ODTLog "Optional tool missing: $($tool.name)" -Level Debug
                }
                continue
            }
            
            # Verify hash if provided in manifest
            if ($tool.sha256) {
                try {
                    $actualHash = (Get-FileHash -Path $toolPath -Algorithm SHA256).Hash
                    if ($actualHash -ne $tool.sha256) {
                        $result.HashMismatches += [PSCustomObject]@{
                            Tool = $tool.name
                            Expected = $tool.sha256
                            Actual = $actualHash
                        }
                        $result.Success = $false
                        Write-ODTLog "Hash mismatch for $($tool.name)" -Level Warning
                    } else {
                        $result.VerifiedCount++
                        Write-ODTLog "Verified: $($tool.name)" -Level Debug
                    }
                } catch {
                    Write-ODTLog "Failed to verify hash for $($tool.name): $_" -Level Warning
                }
            }
        }
        
        if ($result.Success) {
            Write-ODTLog "Tools integrity verification passed ($($result.VerifiedCount) tools verified)" -Level Info
        } else {
            Write-ODTLog "Tools integrity verification FAILED" -Level Error
        }
        
    } catch {
        Write-ODTLog "Error verifying tools integrity: $_" -Level Error
        $result.Success = $false
    }
    
    return $result
}

<#
.SYNOPSIS
    Creates necessary directories if they don't exist
.DESCRIPTION
    Ensures required directories exist with proper error handling
.PARAMETER Paths
    Array of paths to create
#>
function Initialize-Directories {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Paths
    )
    
    foreach ($path in $Paths) {
        try {
            if (-not (Test-Path -Path $path -PathType Container)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                Write-ODTLog "Created directory: $path" -Level Debug
            }
        }
        catch {
            Write-ODTLog "Failed to create directory $path : $_" -Level Error
            throw
        }
    }
}

<#
.SYNOPSIS
    Enables Ctrl+C handling for graceful shutdown
.DESCRIPTION
    Registers event handler for Ctrl+C interruption with cleanup callback
.PARAMETER CleanupScript
    ScriptBlock to execute on interruption for cleanup
.EXAMPLE
    Enable-CtrlCHandling -CleanupScript { Write-Host "Cleaning up..."; Stop-Process $pid }
#>
function Enable-CtrlCHandling {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [scriptblock]$CleanupScript = { Write-ODTLog "Operation interrupted by user" -Level Warning }
    )
    
    try {
        # Check if Ctrl+C handling is enabled in config
        $enableCtrlC = Get-ODTConfigValue -Section "Operations" -Key "EnableCtrlCHandling" -Default $true
        
        if (-not $enableCtrlC) {
            Write-ODTLog "Ctrl+C handling disabled in configuration" -Level Debug
            return
        }
        
        # Register event for Ctrl+C
        $null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
            & $CleanupScript
        } -ErrorAction SilentlyContinue
        
        Write-ODTLog "Ctrl+C handling enabled. Press Ctrl+C to cancel operation." -Level Debug
    }
    catch {
        Write-ODTLog "Failed to enable Ctrl+C handling: $_" -Level Warning
    }
}

<#
.SYNOPSIS
    Disables Ctrl+C handling
.DESCRIPTION
    Unregisters the Ctrl+C event handler
#>
function Disable-CtrlCHandling {
    [CmdletBinding()]
    param()
    
    try {
        Unregister-Event -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue
        Write-ODTLog "Ctrl+C handling disabled" -Level Debug
    }
    catch {
        Write-ODTLog "Failed to disable Ctrl+C handling: $_" -Level Warning
    }
}

<#
.SYNOPSIS
    Checks if operation is in dry-run mode
.DESCRIPTION
    Returns true if -WhatIf or DryRunMode is enabled
.PARAMETER WhatIf
    Standard WhatIf parameter
.OUTPUTS
    Boolean - True if dry-run mode is active
#>
function Test-DryRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf
    )
    
    $configDryRun = Get-ODTConfigValue -Section "Operations" -Key "DryRunMode" -Default $false
    return ($WhatIf -or $configDryRun)
}

<#
.SYNOPSIS
    Executes command with dry-run support
.DESCRIPTION
    Executes command only if not in dry-run mode, otherwise logs what would happen
.PARAMETER Action
    Description of the action
.PARAMETER ScriptBlock
    Script block to execute
.PARAMETER WhatIf
    Standard WhatIf parameter
#>
function Invoke-ODTAction {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Action,
        
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $false)]
        [string]$Target = "System"
    )
    
    if ($PSCmdlet.ShouldProcess($Target, $Action)) {
        Write-ODTLog "Executing: $Action" -Level Info
        try {
            & $ScriptBlock
            Write-ODTLog "Completed: $Action" -Level Info
            return $true
        }
        catch {
            Write-ODTLog "Failed: $Action - $_" -Level Error
            throw
        }
    }
    else {
        Write-ODTLog "[DRY-RUN] Would execute: $Action on $Target" -Level Warning
        return $false
    }
}

<#
.SYNOPSIS
    Loads language strings from language file
.DESCRIPTION
    Reads localized strings from JSON language files
.PARAMETER Language
    Language code (e.g., en-US, it-IT, fr-FR)
.OUTPUTS
    PSCustomObject with localized strings
#>
function Get-LanguageStrings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Language
    )
    
    try {
        # Get language from config if not specified
        if (-not $Language) {
            $Language = Get-ODTConfigValue -Section "General" -Key "Language" -Default "en-US"
        }
        
        $languageFile = Join-Path $PSScriptRoot "Languages" "$Language.json"
        
        if (Test-Path -Path $languageFile) {
            $languageData = Get-Content -Path $languageFile -Raw | ConvertFrom-Json
            return $languageData.Strings
        }
        else {
            Write-Warning "Language file not found: $languageFile. Using English."
            # Fallback to English
            $enFile = Join-Path $PSScriptRoot "Languages" "en-US.json"
            if (Test-Path -Path $enFile) {
                $languageData = Get-Content -Path $enFile -Raw | ConvertFrom-Json
                return $languageData.Strings
            }
            return $null
        }
    }
    catch {
        Write-Warning "Failed to load language strings: $_"
        return $null
    }
}

<#
.SYNOPSIS
    Gets a localized string
.DESCRIPTION
    Retrieves a localized string from language files with format support
.PARAMETER Category
    Category of the string (Common, Security, Operations, etc.)
.PARAMETER Key
    String key name
.PARAMETER Arguments
    Format arguments for string interpolation
.OUTPUTS
    Localized string
#>
function Get-LocalizedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,
        
        [Parameter(Mandatory = $true)]
        [string]$Key,
        
        [Parameter(Mandatory = $false)]
        [object[]]$Arguments
    )
    
    try {
        $strings = Get-LanguageStrings
        if ($strings -and $strings.$Category -and $strings.$Category.$Key) {
            $string = $strings.$Category.$Key
            
            # Apply format arguments if provided
            if ($Arguments) {
                return $string -f $Arguments
            }
            return $string
        }
        else {
            # Return key as fallback
            return "$Category.$Key"
        }
    }
    catch {
        return "$Category.$Key"
    }
}

# Functions are now available for dot-sourcing
# Usage: . "$PSScriptRoot\Common-Functions.ps1"

# Load configuration
Get-ODTConfiguration | Out-Null

# Auto-initialize logging when module is loaded
Initialize-Logging
