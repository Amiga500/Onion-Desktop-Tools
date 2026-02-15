# Language Feature Demo
# This script demonstrates how language switching works in Onion Desktop Tools

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "   Onion Desktop Tools - Language Feature Demo" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

# Import common functions
. "$PSScriptRoot\Common-Functions.ps1"

Write-Host "Demonstrating language support for all 5 languages:" -ForegroundColor Yellow
Write-Host ""

$languages = @(
    @{Code='en-US'; Name='English (US)'; Flag='🇺🇸'},
    @{Code='it-IT'; Name='Italiano'; Flag='🇮🇹'},
    @{Code='fr-FR'; Name='Français'; Flag='🇫🇷'},
    @{Code='es-ES'; Name='Español'; Flag='🇪🇸'},
    @{Code='de-DE'; Name='Deutsch'; Flag='🇩🇪'}
)

foreach ($lang in $languages) {
    Write-Host "$($lang.Flag) $($lang.Name) ($($lang.Code))" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────" -ForegroundColor Gray
    
    try {
        $strings = Get-LanguageStrings -Language $lang.Code
        
        Write-Host "  Common.Yes:            " -NoNewline -ForegroundColor White
        Write-Host $strings.Common.Yes -ForegroundColor Yellow
        
        Write-Host "  Common.No:             " -NoNewline -ForegroundColor White
        Write-Host $strings.Common.No -ForegroundColor Yellow
        
        Write-Host "  Common.Cancel:         " -NoNewline -ForegroundColor White
        Write-Host $strings.Common.Cancel -ForegroundColor Yellow
        
        Write-Host "  Operations.Started:    " -NoNewline -ForegroundColor White
        Write-Host $strings.Operations.OperationStarted -ForegroundColor Yellow
        
        Write-Host "  Format.Started:        " -NoNewline -ForegroundColor White
        Write-Host $strings.Format.FormatStarted -ForegroundColor Yellow
        
        Write-Host ""
    }
    catch {
        Write-Host "  Error loading language: $_" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "HOW TO CHANGE LANGUAGE:" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open config.json in a text editor" -ForegroundColor White
Write-Host "2. Find the 'Language' setting under ODT_Settings > General" -ForegroundColor White
Write-Host "3. Change the value to one of:" -ForegroundColor White
Write-Host "   - en-US (English)" -ForegroundColor Yellow
Write-Host "   - it-IT (Italian)" -ForegroundColor Yellow
Write-Host "   - fr-FR (French)" -ForegroundColor Yellow
Write-Host "   - es-ES (Spanish)" -ForegroundColor Yellow
Write-Host "   - de-DE (German)" -ForegroundColor Yellow
Write-Host "4. Save the file and restart Onion Desktop Tools" -ForegroundColor White
Write-Host ""
Write-Host "Example for Italian:" -ForegroundColor Cyan
Write-Host '  "Language": "it-IT"' -ForegroundColor Yellow
Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "NOTE: The .exe launcher files automatically support all" -ForegroundColor Green
Write-Host "      languages without any modification needed!" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""
