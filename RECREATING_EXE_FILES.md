# Recreating the .exe Launcher Files

This document explains how the two .exe launcher files were recreated for the Onion Desktop Tools project and clarifies their relationship with the new features.

## Background

The project originally included two .exe launcher files in version v0.0.1:
- **Onion Desktop Tools.exe** - Hidden console launcher
- **Onion Desktop Tools - WithConsole.exe** - Visible console launcher

These were created using the Bat_To_Exe_Converter.exe tool from batch file templates. In later versions (v0.0.9), these were replaced with .bat files for easier maintenance and to avoid antivirus false positives.

## Important: Do the .exe Files Need Updating?

**Short Answer: No, the existing .exe files automatically support all new features!**

The .exe launcher files are **simple wrappers** that do the following:
1. Request administrator privileges
2. Create necessary directories (backups, downloads/ODT_updates)
3. Call `ODT_update.ps1`, which then calls `Menu.ps1`

**All application features** (language support, configuration, logging, etc.) are implemented in the PowerShell scripts (`Menu.ps1`, `Common-Functions.ps1`, etc.), **not in the .exe launchers**.

Therefore:
- ✅ Language modification works with existing .exe files
- ✅ Multi-language support (5 languages) works with existing .exe files
- ✅ Enhanced logging works with existing .exe files
- ✅ Configuration system works with existing .exe files
- ✅ All new features work with existing .exe files

The .exe files only need to be regenerated if:
- The launcher logic itself changes (e.g., different startup parameters)
- You want to update the icon or metadata
- The batch file templates are modified

## Files Information

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
- All templates are kept synchronized with the .bat launcher files

## Conversion Tool

The `tools/Bat_To_Exe_Converter.exe` tool is used to convert batch files to exe files. This is a Windows GUI application that:
- Takes a .bat file as input
- Converts it to a standalone .exe file
- Supports options for console visibility, icon customization, etc.
- Embeds the batch script logic into a Windows executable

**Note:** This is a GUI-only tool and requires a Windows machine to operate.

## How to Regenerate (on Windows)

**When to regenerate:** Only if the launcher templates have changed or you need to modify the .exe metadata.

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

- **The .exe files automatically support all new features** because they call the PowerShell scripts
- Language modification, multi-language support, logging, and all other features work without regenerating the .exe files
- The .exe files are functionally equivalent to the .bat launchers
- Both methods request admin privileges and run the auto-updater
- The .exe files may be flagged by some antivirus software (false positive)
- The .bat files are recommended for most users as they are more transparent and easier to maintain
- To use a different language, simply modify the `Language` setting in `config.json` - no .exe regeneration needed

## New Features Support (2026-02-15 Update)

The following features are **fully supported** by the existing .exe launcher files without any modifications:

### ✅ Multi-Language Support (5 Languages)
- English (en-US) - Default
- Italian (it-IT) - Italiano
- French (fr-FR) - Français  
- Spanish (es-ES) - Español
- German (de-DE) - Deutsch

**How to change language:**
1. Open `config.json`
2. Find the `"Language"` setting under `"ODT_Settings"` → `"General"`
3. Change the value to your preferred language code (e.g., `"it-IT"` for Italian)
4. Save the file and restart Onion Desktop Tools

Example:
```json
{
  "ODT_Settings": {
    "General": {
      "Language": "it-IT",
      ...
    }
  }
}
```

### ✅ Other New Features
- Enhanced persistent logging with daily log rotation
- Configuration system via `config.json`
- Security improvements (disk safety validation)
- Tools integrity verification
- Comprehensive test suite
- Dry-run mode for testing
- Ctrl+C handling for graceful interruption

**All these features work immediately** when launching via the .exe files, as they are implemented in the PowerShell scripts that the .exe launchers call.
