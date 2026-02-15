# Recreating the .exe Launcher Files

This document explains how the two .exe launcher files were recreated for the Onion Desktop Tools project.

## Background

The project originally included two .exe launcher files in version v0.0.1:
- **Onion Desktop Tools.exe** - Hidden console launcher
- **Onion Desktop Tools - WithConsole.exe** - Visible console launcher

These were created using the Bat_To_Exe_Converter.exe tool from batch file templates. In later versions (v0.0.9), these were replaced with .bat files for easier maintenance and to avoid antivirus false positives.

## Files Recreated

1. **Onion Desktop Tools.exe** (97,792 bytes) - Launches the tool with hidden console
2. **Onion Desktop Tools - WithConsole.exe** (100,352 bytes) - Launches the tool with visible console

## Source Files

The .exe files are generated from batch file templates:
- `tools/launcher_template_hidden.bat` - Template for hidden console version
- `tools/launcher_template_console.bat` - Template for visible console version

These templates include:
- Admin privilege elevation check
- Directory setup (backups, downloads/ODT_updates)
- Auto-update functionality via ODT_update.ps1

## Conversion Tool

The `tools/Bat_To_Exe_Converter.exe` tool is used to convert batch files to exe files. This is a Windows GUI application that:
- Takes a .bat file as input
- Converts it to a standalone .exe file
- Supports options for console visibility, icon customization, etc.

## How to Regenerate (on Windows)

If you need to regenerate the .exe files on a Windows machine:

1. Open `tools/Bat_To_Exe_Converter.exe`
2. For the hidden console version:
   - Load `tools/launcher_template_hidden.bat`
   - Configure settings:
     - Title: "Onion Desktop Tools"
     - Invisible application: Yes
     - Administrator privileges: Yes
   - Save as: `Onion Desktop Tools.exe`
3. For the console version:
   - Load `tools/launcher_template_console.bat`
   - Configure settings:
     - Title: "Onion Desktop Tools - With Console"
     - Invisible application: No
     - Administrator privileges: Yes
   - Save as: `Onion Desktop Tools - WithConsole.exe`

## Alternative Launch Methods

Users can alternatively use the provided .bat files:
- `_Onion Desktop Tools - Launcher.bat` - Hidden console
- `_Onion Desktop Tools - Launcher (With Console).bat` - Visible console

These .bat files offer the same functionality as the .exe files but may be preferred to avoid antivirus warnings.

## Notes

- The .exe files are functionally equivalent to the .bat launchers
- Both methods request admin privileges and run the auto-updater
- The .exe files may be flagged by some antivirus software (false positive)
- The .bat files are recommended for most users as they are more transparent and easier to maintain
