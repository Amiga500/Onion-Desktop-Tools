# EXE File Verification Checklist

This checklist helps verify that the .exe launcher files are correctly configured and functioning properly.

## Quick Check: Is Your .exe File Correct?

### Problem Symptoms:
- ❌ Window title shows text without spaces (e.g., "OnionDesktopTools")
- ❌ Console window shows English text even when Italian is configured
- ❌ Application fails to launch or crashes immediately

### Quick Solution:
**Use the .bat launcher files instead!** They work identically and don't have title formatting issues:
- `_Onion Desktop Tools - Launcher.bat` (hidden console)
- `_Onion Desktop Tools - Launcher (With Console).bat` (visible console)

## Full Verification Process

### Step 1: Visual Inspection

1. **File Size Check**:
   - `Onion Desktop Tools.exe` should be approximately 97-98 KB
   - `Onion Desktop Tools - WithConsole.exe` should be approximately 100-101 KB

2. **Launch Test**:
   - Double-click `Onion Desktop Tools - WithConsole.exe`
   - The console window title should read: **"Onion Desktop Tools - With Console"** (with spaces)
   - The PowerShell GUI should appear with your configured language

3. **Language Test**:
   - Set `"Language": "it-IT"` in `config.json`
   - Launch the application
   - The PowerShell GUI should display in Italian
   - Note: The console window title will always be in English (embedded in .exe)

### Step 2: Common Issues and Fixes

#### Issue 1: Title Without Spaces
**Symptom**: Window shows "OnionDesktopTools" or similar without spaces

**Cause**: .exe was created with incorrect title field in Bat_To_Exe_Converter

**Fix**: Regenerate the .exe following these exact steps:

1. Open `tools/Bat_To_Exe_Converter.exe` on a Windows machine
2. Load the appropriate template file
3. **CRITICAL**: In the "Title" or "Window Name" field, enter:
   - For hidden version: `Onion Desktop Tools` (with spaces!)
   - For console version: `Onion Desktop Tools - With Console` (with spaces!)
4. Check "Administrator privileges" option
5. Set "Invisible application" correctly (Yes for hidden, No for console)
6. Compile and save

#### Issue 2: Application Doesn't Launch
**Symptom**: Double-clicking .exe does nothing or shows error

**Possible Causes**:
- Missing PowerShell scripts (Menu.ps1, ODT_update.ps1)
- Incorrect working directory
- Insufficient permissions
- Antivirus blocking execution

**Fix**:
1. Ensure all .ps1 files are in the same directory as the .exe
2. Right-click .exe → "Run as Administrator"
3. Check antivirus logs and add exception if needed
4. Try using .bat launcher files instead

#### Issue 3: Language Not Working
**Symptom**: GUI shows English despite Italian in config.json

**Diagnosis**:
1. Check `config.json` has correct format:
   ```json
   {
     "ODT_Settings": {
       "General": {
         "Language": "it-IT"
       }
     }
   }
   ```
2. Verify `Languages/it-IT.json` exists
3. Check for errors in console output (use WithConsole version)

**Note**: Console window title from .exe is always embedded and won't change with language settings. This is normal and expected.

### Step 3: Regeneration Instructions (if needed)

If verification fails, regenerate the .exe files:

**See detailed instructions in**:
- [RECREATING_EXE_FILES.md](RECREATING_EXE_FILES.md) - English
- [RECREATING_EXE_FILES_IT.md](RECREATING_EXE_FILES_IT.md) - Italian

**Key Points**:
- ✅ Use exact title: `Onion Desktop Tools` (with spaces)
- ✅ Enable "Administrator privileges"
- ✅ Set "Invisible application" correctly
- ✅ Use correct template file
- ✅ Test after creating

### Step 4: Alternative Solution

**Recommended**: Use .bat launcher files instead of .exe files:

**Advantages of .bat launchers**:
- ✅ More transparent (you can read the code)
- ✅ Less likely to trigger antivirus
- ✅ Easier to modify if needed
- ✅ No title formatting issues
- ✅ Functionally identical to .exe files

**Files**:
- `_Onion Desktop Tools - Launcher.bat` (hidden console)
- `_Onion Desktop Tools - Launcher (With Console).bat` (visible console)

## Summary

### Working Correctly?
- ✅ Console title has proper spacing
- ✅ GUI displays in configured language
- ✅ All features work normally
→ **No action needed**

### Having Issues?
- ❌ Title without spaces
- ❌ Language not working
- ❌ Won't launch
→ **Use .bat launchers OR regenerate .exe files**

## Support

For more help:
- Read [README.md](README.md) for general usage
- Check [RECREATING_EXE_FILES.md](RECREATING_EXE_FILES.md) for .exe creation
- See [LANGUAGE_GUIDE.md](LANGUAGE_GUIDE.md) for language configuration
- Review [CODE_REVIEW.md](CODE_REVIEW.md) for technical details

## Quick Reference

| File | Purpose | Console | Admin |
|------|---------|---------|-------|
| `Onion Desktop Tools.exe` | Launch with hidden console | Hidden | Yes |
| `Onion Desktop Tools - WithConsole.exe` | Launch with visible console | Visible | Yes |
| `_Onion Desktop Tools - Launcher.bat` | Launch with hidden console | Hidden | Yes |
| `_Onion Desktop Tools - Launcher (With Console).bat` | Launch with visible console | Visible | Yes |

**All four options are functionally equivalent** - choose based on preference.
