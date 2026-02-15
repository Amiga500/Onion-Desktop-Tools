# Common-Functions.ps1 - Shared utility functions for Onion Desktop Tools
# Version: 1.1.0

#Requires -Version 5.1

Set-StrictMode -Version Latest

# Global error action preference for the module
$ErrorActionPreference = 'Stop'

# Global logging configuration
$script:LogDirectory = Join-Path $PSScriptRoot "logs"
$script:LogFileName = "ODT_$(Get-Date -Format 'yyyy-MM-dd').log"
$script:LogFilePath = Join-Path $script:LogDirectory $script:LogFileName
$script:EnableFileLogging = $true
$script:MaxLogSizeMB = 10
$script:MaxLogFiles = 30

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
    Computes and verifies the hash of a file against an expected value
.PARAMETER FilePath
    Path to the file to verify
.PARAMETER ExpectedHash
    Expected hash value
.PARAMETER Algorithm
    Hash algorithm to use (default: SHA256)
.OUTPUTS
    Boolean - True if hash matches, False otherwise
#>
function Test-FileHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$ExpectedHash,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('SHA256', 'SHA1', 'MD5')]
        [string]$Algorithm = 'SHA256'
    )
    
    try {
        if (-not (Test-Path -Path $FilePath)) {
            Write-Error "File not found: $FilePath"
            return $false
        }
        
        $actualHash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
        $match = $actualHash -eq $ExpectedHash
        
        if (-not $match) {
            Write-Warning "Hash mismatch for $FilePath"
            Write-Warning "Expected: $ExpectedHash"
            Write-Warning "Actual: $actualHash"
        }
        
        return $match
    }
    catch {
        Write-Error "Error computing file hash: $_"
        return $false
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

# Functions are now available for dot-sourcing
# Usage: . "$PSScriptRoot\Common-Functions.ps1"

# Auto-initialize logging when module is loaded
Initialize-Logging
