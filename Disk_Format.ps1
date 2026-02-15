#Requires -Version 5.1
#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory = $false)]
    [string]$Drive_Number
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Drive_Number) {
    Write-Host "This script requires a drive number argument."
    Write-Host "Usage: Disk_Format.ps1 -Drive_Number <drive_number>"
    exit 1
}

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDirectory = Split-Path $ScriptPath -Parent
Set-Location -Path $ScriptDirectory
[Environment]::CurrentDirectory = Get-Location

# Import common functions
$commonFunctionsPath = Join-Path -Path $PSScriptRoot -ChildPath "Common-Functions.ps1"
if (Test-Path -Path $commonFunctionsPath) {
    . $commonFunctionsPath
} else {
    Write-Error "Common-Functions.ps1 not found. Cannot continue."
    exit 1
}

# Verify we're running as administrator
if (-not (Test-IsAdministrator)) {
    Write-Error "This script requires administrator privileges."
    exit 1
}


#$Drive_Number = 6

Write-ODTLog "Drive Number in script arg: $Drive_Number" -Level Info

# CRITICAL SECURITY CHECK: Validate disk is safe to format
$driveLetter = $null
try {
    $driveLetter = GetLetterFromDriveNumber
    
    if ($driveLetter) {
        Write-ODTLog "Drive letter detected: $driveLetter" -Level Info
        
        # Perform safety validation
        $isSafe = Test-IsSafeDiskToFormat -DriveNumber ([int]$Drive_Number) -DriveLetter $driveLetter
        
        if (-not $isSafe) {
            $errorMsg = "SECURITY ERROR: Drive $Drive_Number ($driveLetter) failed safety checks.`n`nThis might be a system disk or contain critical files.`n`nFormatting has been BLOCKED to prevent data loss."
            Write-ODTLog $errorMsg -Level Error
            [System.Windows.Forms.MessageBox]::Show(
                $errorMsg,
                "Format Blocked - Safety Check Failed",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            exit 1
        }
        Write-ODTLog "Disk safety check passed" -Level Info
    }
} catch {
    Write-ODTLog "Error during safety check: $_" -Level Error
    [System.Windows.Forms.MessageBox]::Show(
        "Failed to validate disk safety. Formatting cancelled for security reasons.`n`nError: $_",
        "Safety Check Failed",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}


function GetLetterFromDriveNumber {
    $commandOutput = & "tools\RMPARTUSB.exe" "drive=$Drive_Number" "GETDRV"
    $driveLetterPattern = 'SET USBDRIVELETTER=(.+)'
    $driveLetterMatch = $commandOutput | Select-String -Pattern $driveLetterPattern
     Write-Host "driveLetterMatch1: $driveLetterMatch"
    if ($driveLetterMatch) {
        $driveLetter = $driveLetterMatch.Matches.Groups[1].Value
        Write-Host "Drive Letter: $driveLetter"
        return $driveLetter  # Retourner la valeur de $driveLetter
    }
    else {
        Write-Host "Drive Letter not found"
        return $null  # Retourner $null si la lettre de lecteur n'est pas trouv�e
    }
}



$driveLetter = GetLetterFromDriveNumber

# if the drive ha already a letter affected :
Write-Host "driveLetterMatch2: $driveLetterMatch"
if ($driveLetter -ne $null) {

    # if some files are already here, we alert the user that all is going to be erased.
    $items = Get-ChildItem -Path "$($driveLetter)\"

    # Vérifier si la carte SD est vierge
    if ($items.Count -eq 0) {
        #################### empty partition ####################
        Write-Host "Blank SD card."
        $messageBoxText = "It seems that your SD card is empty so no backup required.`n" + 
        "Continue ?`n`n"
    }
    else {
        Write-Host "The SD card contains files/folders."
        Write-Host "Looking for a previous Onion installation in ${driveLetter}\.tmp_update\onionVersion\version.txt"
        $verionfilePath = "${driveLetter}\.tmp_update\onionVersion\version.txt"
        if (Test-Path -Path $verionfilePath -PathType Leaf) {
            #################### previous Onion ####################
            $content = Get-Content -Path $verionfilePath -Raw
            Write-Host "Onion version $content already installed on this SD card."
            $messageBoxText = "Onion $content is installed on this SD card.`n" +
            "Are you sure that you want to format the SD card?`n`n" +
            "(Saves, roms, configuration: everything will be lost!)"
        }
        elseif ((Test-Path -Path "${Target}\.tmp_update") -and (Test-Path -Path "${Target}\miyoo\app\.tmp_update\onion.pak")) {
            #################### Fresh Onion install files (not executed on MM) ####################
            Write-Host "It seems to be and non installed Onion version"
            $label_right.Text += "`r`nFresh Onion install files on ${Target}"
            Write-Host "It seems to be and non installed Onion version."
            $messageBoxText = "It seems to be and non installed Onion version.`n" +
            "Are you sure that you want to format the SD card?`n`n" +
            "(Saves, roms, configuration: everything will be lost!)"
        }
        elseif (Test-Path -Path "${driveLetter}\RApp\") {
            #################### previous Stock ####################
            Write-Host "It seems to be a stock SD card from Miyoo"
            $messageBoxText = "It seems to be a stock SD card from Miyoo.`n" +
            "Are you sure that you want to format the SD card?`n`n" +
            "(Saves, roms, configuration: everything will be lost!)`n`n" +
            "Note that it's not recommended to install Onion on the `n" +
            "stock SD card (as the quality is not good you could have`n" +
            "data corruption which may prevent Onion from working properly)."

        }
        else {
            #################### unknown files ####################
            Write-Host "Not Onion or Stock"
            $messageBoxText = "It seems that your SD card contains some files.`n" +
            "Are you sure that you want to format the SD card?`n`n" +
            "(Everything on the SD card will be lost!)"
        }
    }
}
else {
    #################### No partition ####################
    Write-Host "No partition recognized by Windows : SD card not formated or unknown partition type."
    $messageBoxText = "It seems that your SD card is not formated`n" + 
    "(or contains an unknown partition type as EXT/linux).`n" +
    "Are you sure that you want to format the SD card?`n`n" +
    "(Everything on the SD card will be lost!)"
}

$messageBoxCaption = "Formating Confirmation"
$messageBoxButtons = [System.Windows.Forms.MessageBoxButtons]::YesNo
$messageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Warning
$result = [System.Windows.Forms.MessageBox]::Show($messageBoxText, $messageBoxCaption, $messageBoxButtons, $messageBoxIcon)

if ($result -eq [System.Windows.Forms.DialogResult]::No) {
    Write-ODTLog "Format cancelled by user" -Level Info
    exit 1  # Exit script with error code 1
}

try {
    Write-ODTLog "Unlocking drive in case of some apps hooks the drive." -Level Info
    .\tools\LockHunter\LockHunter32.exe /unlock $driveLetter /kill /silent
    
    # formating (SURE option arg is not implemented -> some popups but gives some additional information during formating) 
    Write-ODTLog "Start formatting..." -Level Info
    
    & .\tools\RMPARTUSB-old.exe drive=$Drive_Number WINPE FAT32 NOACT VOLUME=Onion
    
    # Check the exit code
    if ($LASTEXITCODE -ne 0) {
        Write-ODTLog "An error occurred while executing RMPARTUSB-old.exe. Exit code: $LASTEXITCODE" -Level Error
        exit 2  # Exit the script with error code 2
    } else {
        Write-ODTLog "Format command executed successfully." -Level Info
    }
    
    Start-Sleep -Seconds 5
    $driveLetter = GetLetterFromDriveNumber
    
} catch {
    Write-ODTLog "Critical error during format operation: $_" -Level Error
    [System.Windows.Forms.MessageBox]::Show(
        "Format operation failed with error:`n`n$_",
        "Format Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 2
}


