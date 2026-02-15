# Changelog - Onion Desktop Tools

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Security & Quality Improvements

### Added - Phase 3 (2026-02-15)
- **Enhanced Configuration System**
  - Added `ODT_Settings` section to config.json
  - Configuration for: LogLevel, EnablePersistentLogging, DryRunMode, Language, etc.
  - New functions: `Get-ODTConfiguration()`, `Get-ODTConfigValue()`
  - Automatic loading of configuration on startup
- **Unit Testing Framework**
  - Implemented Pester test framework infrastructure
  - Created `Tests/` directory with test suite
  - Added `Common-Functions.Tests.ps1` with comprehensive tests
  - Created `Run-Tests.ps1` test runner with coverage support
  - Tests for: Configuration, Admin checks, Disk validation, Logging, Dry-run, Ctrl+C handling
- **Ctrl+C Handling**
  - New functions: `Enable-CtrlCHandling()`, `Disable-CtrlCHandling()`
  - Graceful cleanup on user interruption
  - Configurable via `EnableCtrlCHandling` in config.json
  - Event-based interruption handling
- **Dry-Run Mode**
  - Implemented `-WhatIf` parameter support
  - New functions: `Test-DryRun()`, `Invoke-ODTAction()`
  - Preview destructive operations without executing
  - Configurable via `DryRunMode` in config.json
- **Multi-Language Support**
  - Created `Languages/` directory structure
  - Implemented `en-US.json` language file
  - New functions: `Get-LanguageStrings()`, `Get-LocalizedString()`
  - Support for string interpolation with format arguments
  - Language selection via config.json
- **PowerShell 7 Compatibility**
  - Tested on PowerShell 7.4.13
  - Maintained backward compatibility with 5.1+
  - All scripts work on both versions

### Added - Phase 2 (2026-02-15)
- **Persistent Logging System**
  - Automatic daily log files in `logs/` directory
  - Log file rotation (keeps 30 days of logs)
  - Size-based rotation (10MB limit per file)
  - Session markers in logs for easy debugging
  - `Initialize-Logging()` function for setup
- **Tools Integrity Verification**
  - `tools_manifest.json` with SHA256 checksums for all 10 external tools
  - Required vs optional tool classification
  - Source URLs and version documentation
  - `Test-ToolsIntegrity()` function for verification on startup
  - Warns on hash mismatches but doesn't block operation
- **Enhanced File Verification**
  - Improved `Test-FileHash()` with detailed result objects
  - Automatic size verification against GitHub asset info
  - Hash computation with logging
  - Integration with download verification
- **.gitignore File**
  - Excludes logs directory
  - Excludes downloaded zip files
  - Excludes temporary and backup files
  - Prevents committing user-specific data

### Added - Phase 1 (2026-02-15)
- **CRITICAL**: New `Common-Functions.ps1` module with security utilities
- **CRITICAL**: `Test-IsSafeDiskToFormat()` function to prevent formatting system disks
  - Checks for system drive (C:)
  - Validates for Windows directory
  - Validates for Program Files
  - Warns if disk is larger than 512GB
- `Test-IsAdministrator()` function to verify admin privileges
- `Test-FileHash()` function for file integrity verification
- `Write-ODTLog()` centralized logging with timestamps and severity levels
- `Test-RequiredTools()` to verify presence of external executables
- `Initialize-Directories()` for safe directory creation with error handling
- `Invoke-ExternalCommand()` wrapper for external process execution
- Comprehensive `CODE_REVIEW.md` document (in Italian) with:
  - Detailed security analysis
  - Code quality assessment
  - Refactoring recommendations
  - Metrics and ratings
- SHA256 hash computation for downloaded Onion OS files
- Security notes in README.md
- System requirements documentation

### Changed
- **CRITICAL**: `Disk_Format.ps1` now validates disk safety before formatting
- **CRITICAL**: All critical scripts now require administrator privileges (#Requires -RunAsAdministrator)
- All PowerShell scripts now use `Set-StrictMode -Version Latest`
- All PowerShell scripts now specify `#Requires -Version 5.1`
- Improved error handling with try-catch blocks in:
  - `Disk_Format.ps1` - Format operations
  - `Onion_Install_Download.ps1` - Download operations
  - `Onion_Install_Extract.ps1` - Extraction operations
  - `ODT_update.ps1` - Self-update operations
  - `PC_WifiInfo.ps1` - WiFi profile retrieval
- Enhanced error messages with troubleshooting information
- Improved logging throughout the application
- Better user feedback for destructive operations

### Fixed
- Missing administrator privilege checks
- Lack of disk validation before format (could format system drive)
- Insufficient error handling in file operations
- Missing cleanup in temporary WiFi export directory
- No verification of downloaded file integrity

### Security
- **CRITICAL FIX**: Disk format operations now block system drive formatting
- **CRITICAL FIX**: Administrator privilege verification on critical operations
- Hash verification (SHA256) for downloaded files (manual verification for now)
- Improved validation of user inputs
- Better error messages to prevent user mistakes

## [0.0.9] - Previous Release
- Auto update functionality
- Format SD card in FAT32
- Check disk of SD card
- Download latest Onion OS version (stable or beta)
- Update / install / repair Onion
- Backup / restore SD card
- Onion OS configuration manager
- Onion OS emulators and applications manager
- Onion OS WiFi manager

---

## Migration Notes

### For Users
- **You must run Onion Desktop Tools as Administrator** - This is now enforced
- The tool will now validate that you're not accidentally formatting a system drive
- Downloaded files now show SHA256 hash for manual verification
- Error messages are more detailed and helpful

### For Developers
- New `Common-Functions.ps1` must be present for critical security functions
- All scripts now use stricter PowerShell settings (#Requires, Set-StrictMode)
- Use `Write-ODTLog` instead of `Write-Host` for consistent logging
- Import common functions at the start of scripts: `. "$PSScriptRoot\Common-Functions.ps1"`

---

## Roadmap

### ✅ Priority 1 - COMPLETED (Phase 2)
- [x] **Persistent logging to file by default** - IMPLEMENTED with daily logs, auto-rotation
- [x] **Tools manifest with version pinning and checksums** - IMPLEMENTED with SHA256 verification
- [ ] Automatic hash verification against GitHub release assets - PARTIAL (manual verification implemented)

### ✅ Priority 2 - COMPLETED (Phase 3)
- [x] **Enhanced configuration via config.json** - IMPLEMENTED with ODT_Settings section
- [x] **Unit tests using Pester framework** - IMPLEMENTED with test suite and runner
- [x] **Ctrl+C handling for long operations** - IMPLEMENTED with graceful cleanup
- [x] **Dry-run mode for destructive operations** - IMPLEMENTED with -WhatIf support

### 🔄 Priority 3 - PARTIALLY IMPLEMENTED (Phase 3)
- [x] **PowerShell 7 compatibility** - TESTED and compatible (5.1+ required)
- [x] **Multi-language support** - IMPLEMENTED with en-US strings, infrastructure ready
- [ ] Advanced disk imaging features - DEFERRED (future consideration)

---

## Credits

**Original Author:** Schmurtz (Onion Team)  
**Security Improvements:** Code Review 2026-02-15  
**License:** GPL v3
