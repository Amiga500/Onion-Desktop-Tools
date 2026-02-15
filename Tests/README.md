# Onion Desktop Tools - Test Suite

## Overview

This directory contains the Pester test suite for Onion Desktop Tools. The tests validate functionality of the PowerShell modules and functions.

## Requirements

- **PowerShell**: 5.1 or later (tested on PowerShell 7.4+)
- **Pester**: Version 5.0 or later

## Installation

If Pester is not installed, the test runner will automatically install it. You can also install manually:

```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
```

## Running Tests

### Run All Tests

```powershell
.\Run-Tests.ps1
```

### Run with Coverage

```powershell
.\Run-Tests.ps1 -Coverage
```

### Run Specific Test File

```powershell
.\Run-Tests.ps1 -TestPath ".\Tests\Common-Functions.Tests.ps1"
```

### Generate Test Results (NUnit XML)

```powershell
.\Run-Tests.ps1 -OutputFormat NUnitXml
```

## Test Structure

### Common-Functions.Tests.ps1

Tests for the core utility functions module including:

- **Configuration Functions**: Loading and accessing configuration
- **Administrator Check**: Privilege verification
- **Disk Safety Validation**: System disk protection
- **Logging Functions**: Log writing and formatting
- **Dry-Run Functions**: WhatIf and dry-run mode
- **Tools Integrity**: Manifest verification
- **Ctrl+C Handling**: Interruption handling

## Test Coverage

The test suite aims to cover:

- ✅ Configuration loading and parsing
- ✅ Security checks (admin, disk validation)
- ✅ Logging functionality
- ✅ Dry-run mode
- ✅ Ctrl+C handling
- ✅ Tools integrity verification
- 🔄 Future: Format operations
- 🔄 Future: Download operations
- 🔄 Future: Extract operations

## Writing New Tests

Follow the Pester 5 syntax:

```powershell
Describe "Feature Name" {
    Context "Specific Scenario" {
        It "Should do something" {
            # Arrange
            $input = "test"
            
            # Act
            $result = Do-Something $input
            
            # Assert
            $result | Should -Be "expected"
        }
    }
}
```

## Test Output

Test results are saved to:
- `testresults.nunitxml` (if NUnit format selected)
- `testresults.junitxml` (if JUnit format selected)
- `coverage.xml` (if coverage enabled)

## CI/CD Integration

Tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Tests
  run: |
    pwsh -File Run-Tests.ps1 -Coverage -OutputFormat NUnitXml
```

## Troubleshooting

### Pester Version Conflicts

If you have multiple Pester versions:

```powershell
Get-Module -ListAvailable Pester
Import-Module Pester -MinimumVersion 5.0 -Force
```

### Permission Errors

Some tests may require administrator privileges:

```powershell
# Run PowerShell as Administrator
Start-Process pwsh -Verb RunAs -ArgumentList "-File Run-Tests.ps1"
```

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure tests pass before committing
3. Maintain test coverage above 80%
4. Document test scenarios in comments

## Resources

- [Pester Documentation](https://pester.dev/)
- [PowerShell Testing Guide](https://docs.microsoft.com/powershell/scripting/dev-cross-plat/test-cmdlets-pester)
