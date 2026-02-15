# Onion-Desktop-Tools
A software to install and configure Onion OS for Miyoo Mini

[Download Onion Desktop Tools.](https://github.com/schmurtzm/Onion-Desktop-Tools/archive/refs/tags/v0.0.9.zip)

Onion Desktop Tools is a Windows program that simplifies the preparation of a micro SD card for Onion.

Onion Desktop Tools will help you to format the SD card, download, install, update and configure Onion in an really easy way.

## ⚠️ Important Security Notes

**This tool performs destructive disk operations. Please read carefully:**

- ✅ **Run as Administrator**: Required for disk operations
- ✅ **Verify selected disk**: Double-check you've selected the correct SD card before formatting
- ✅ **Backup important data**: Always backup your data before formatting
- ✅ **System disk protection**: The tool includes checks to prevent formatting system disks, but always verify manually
- ✅ **Antivirus warnings**: Some antivirus may flag the tool due to disk operations - this is expected behavior

**Best Practices:**
1. Remove unnecessary USB drives before running the tool
2. Verify the drive letter and size match your SD card
3. Use genuine, high-quality SD cards (avoid stock SD cards for best results)
4. Keep backups of your ROM saves using the built-in backup feature

# Features : 
- auto update itself
- format SD card in FAT32
- Check disk of SD card
- Download last Onion OS version (stable or beta)
- update / install / repair Onion
- backup / restore SD card (also allows migration from stock SD card to Onion SD card)
- Onion OS configuration Manager
- Onion OS EMulators and Applications Manager
- Onion OS wifi Manager

------------------------------------------------

# System Requirements

- Windows 10 or later
- PowerShell 5.1 or later (included in Windows 10+)
- Administrator privileges
- SD card reader
- Internet connection (for downloading Onion OS)

# Video Tutorials

A tutorial video about Onion Desktop Tool, it describes the process for preparing a new fresh SD card (click on the picture to view it) :

[![Onion Desktop Tool - Video Presentation](https://img.youtube.com/vi/moE52Dw2x64/0.jpg)](https://youtu.be/moE52Dw2x64])

An advanced tutorial video about Onion Desktop Tool,  (click on the picture to view it)
- Onion OS Configurator
- Emulators and applications manager
- Wifi Configurator
- Backup SD card for Stock SD Card and Onion
- Restore a backup on Onion SD card
- SD card tools (format SD card in FAT32 or run a check disk easily)


[![Onion Desktop Tool - Video Presentation](https://img.youtube.com/vi/QyzKe8Lqdi8/0.jpg)](https://youtu.be/QyzKe8Lqdi8])

------------------------------------------------

# Security & Error Handling

**Recent Improvements (v0.0.10+):**

**Phase 1 - Security Hardening:**
- ✅ Enhanced disk validation to prevent accidental system disk formatting
- ✅ Comprehensive error handling with detailed logging
- ✅ SHA256 hash computation for downloaded files
- ✅ Administrator privilege verification
- ✅ Improved error messages for troubleshooting

**Phase 2 - Operational Excellence:**
- ✅ Persistent logging system (daily logs, auto-rotation)
- ✅ Tools integrity verification (SHA256 checksums for 10 tools)
- ✅ Enhanced file verification (size + hash checks)
- ✅ Complete audit trail for debugging

**Logging:**
- All operations are logged to console with timestamps
- Persistent logging enabled by default (logs/ directory, auto-rotation)
- Daily log files with 30-day retention and 10MB size limit
- Error details include actionable troubleshooting steps

For detailed security analysis and code quality review, see [CODE_REVIEW.md](CODE_REVIEW.md).

------------------------------------------------

# Presentation :

# Dev informations : 
Onion Desktop Tools is developped in powershell.
