# Run-Tests.ps1 - Test runner for Onion Desktop Tools

<#
.SYNOPSIS
    Runs Pester tests for Onion Desktop Tools
.DESCRIPTION
    Executes all test files in the Tests directory and generates coverage report
.PARAMETER TestPath
    Path to specific test file or directory (default: Tests/)
.PARAMETER Coverage
    Generate code coverage report
.PARAMETER OutputFormat
    Output format (NUnitXml, JUnitXml, or None)
.EXAMPLE
    .\Run-Tests.ps1
.EXAMPLE
    .\Run-Tests.ps1 -Coverage -OutputFormat NUnitXml
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TestPath = ".\Tests\",
    
    [Parameter(Mandatory = $false)]
    [switch]$Coverage,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('NUnitXml', 'JUnitXml', 'None')]
    [string]$OutputFormat = 'None'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host " Onion Desktop Tools - Test Runner" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Pester is installed
try {
    $pesterModule = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
    
    if (-not $pesterModule) {
        Write-Host "Pester module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
        Write-Host "Pester installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Found Pester version: $($pesterModule.Version)" -ForegroundColor Green
    }
    
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
}
catch {
    Write-Error "Failed to import Pester module: $_"
    Write-Host ""
    Write-Host "Please install Pester manually:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Pester -Force -SkipPublisherCheck" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Configure Pester
$pesterConfiguration = New-PesterConfiguration
$pesterConfiguration.Run.Path = $TestPath
$pesterConfiguration.Run.PassThru = $true
$pesterConfiguration.Output.Verbosity = 'Detailed'

if ($Coverage) {
    Write-Host "Enabling code coverage analysis..." -ForegroundColor Cyan
    $pesterConfiguration.CodeCoverage.Enabled = $true
    $pesterConfiguration.CodeCoverage.Path = @(
        '.\Common-Functions.ps1',
        '.\Disk_Format.ps1',
        '.\Disk_selector.ps1'
    )
    $pesterConfiguration.CodeCoverage.OutputFormat = 'JaCoCo'
    $pesterConfiguration.CodeCoverage.OutputPath = '.\Tests\coverage.xml'
}

if ($OutputFormat -ne 'None') {
    Write-Host "Output format: $OutputFormat" -ForegroundColor Cyan
    $pesterConfiguration.TestResult.Enabled = $true
    $pesterConfiguration.TestResult.OutputFormat = $OutputFormat
    $pesterConfiguration.TestResult.OutputPath = ".\Tests\testresults.$($OutputFormat.ToLower())"
}

Write-Host ""
Write-Host "Running tests..." -ForegroundColor Cyan
Write-Host ""

# Run tests
try {
    $result = Invoke-Pester -Configuration $pesterConfiguration
    
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host " Test Results Summary" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Tests: $($result.TotalCount)" -ForegroundColor White
    Write-Host "Passed:      $($result.PassedCount)" -ForegroundColor Green
    Write-Host "Failed:      $($result.FailedCount)" -ForegroundColor $(if ($result.FailedCount -gt 0) { 'Red' } else { 'Green' })
    Write-Host "Skipped:     $($result.SkippedCount)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Coverage -and $result.CodeCoverage) {
        Write-Host "Code Coverage:" -ForegroundColor Cyan
        Write-Host "  Covered:    $($result.CodeCoverage.NumberOfCommandsExecuted)" -ForegroundColor Green
        Write-Host "  Missed:     $($result.CodeCoverage.NumberOfCommandsMissed)" -ForegroundColor Yellow
        Write-Host "  Total:      $($result.CodeCoverage.NumberOfCommandsAnalyzed)" -ForegroundColor White
        
        if ($result.CodeCoverage.NumberOfCommandsAnalyzed -gt 0) {
            $coveragePercent = [math]::Round(($result.CodeCoverage.NumberOfCommandsExecuted / $result.CodeCoverage.NumberOfCommandsAnalyzed) * 100, 2)
            Write-Host "  Percentage: $coveragePercent%" -ForegroundColor $(if ($coveragePercent -ge 80) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' })
        }
        Write-Host ""
    }
    
    if ($result.FailedCount -gt 0) {
        Write-Host "Some tests failed. Please review the output above." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "All tests passed! ✓" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Error "Test execution failed: $_"
    exit 1
}
