# Guida Rapida: Modifica della Lingua / Quick Guide: Language Modification

## 🇮🇹 Per Utenti Italiani

### I file .exe supportano già tutte le nuove funzionalità! ✅

**Importante:** I file `.exe` launcher (`Onion Desktop Tools.exe` e `Onion Desktop Tools - WithConsole.exe`) sono semplici wrapper che chiamano gli script PowerShell. Tutte le funzionalità, incluso il supporto multilingua, sono implementate negli script PowerShell, NON nei file .exe.

Questo significa che:
- ✅ La modifica della lingua funziona immediatamente con i file .exe esistenti
- ✅ Non è necessario rigenerare i file .exe per cambiare lingua
- ✅ Tutte le 5 lingue sono già supportate

### Come Cambiare la Lingua

1. **Apri il file `config.json`** con un editor di testo (Notepad, Notepad++, ecc.)

2. **Trova la sezione Language:**
   ```json
   {
     "ODT_Settings": {
       "General": {
         "Language": "en-US",
         ...
       }
     }
   }
   ```

3. **Cambia il valore in `it-IT` per l'italiano:**
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

4. **Salva il file** e riavvia Onion Desktop Tools

### Lingue Disponibili

- `en-US` - English (US) 🇺🇸
- `it-IT` - Italiano 🇮🇹
- `fr-FR` - Français 🇫🇷
- `es-ES` - Español 🇪🇸
- `de-DE` - Deutsch 🇩🇪

### Demo

Per vedere una dimostrazione di tutte le lingue, esegui:
```powershell
.\Demo-Language-Feature.ps1
```

### Domande Frequenti

**Q: Devo rigenerare i file .exe per usare una lingua diversa?**
A: No! I file .exe esistenti supportano già tutte le lingue.

**Q: Come posso verificare che la lingua sia stata cambiata?**
A: Dopo aver modificato `config.json` e riavviato l'applicazione, tutti i messaggi appariranno nella lingua selezionata.

**Q: Posso usare i file .bat invece dei .exe?**
A: Sì! I file `_Onion Desktop Tools - Launcher.bat` e `_Onion Desktop Tools - Launcher (With Console).bat` funzionano esattamente come i file .exe e supportano anch'essi tutte le lingue.

---

## 🇬🇧 For English Users

### The .exe files already support all new features! ✅

**Important:** The `.exe` launcher files (`Onion Desktop Tools.exe` and `Onion Desktop Tools - WithConsole.exe`) are simple wrappers that call PowerShell scripts. All features, including multi-language support, are implemented in the PowerShell scripts, NOT in the .exe files.

This means:
- ✅ Language modification works immediately with existing .exe files
- ✅ No need to regenerate .exe files to change language
- ✅ All 5 languages are already supported

### How to Change Language

1. **Open `config.json`** with a text editor (Notepad, Notepad++, etc.)

2. **Find the Language section:**
   ```json
   {
     "ODT_Settings": {
       "General": {
         "Language": "en-US",
         ...
       }
     }
   }
   ```

3. **Change the value to your preferred language:**
   ```json
   {
     "ODT_Settings": {
       "General": {
         "Language": "fr-FR",
         ...
       }
     }
   }
   ```

4. **Save the file** and restart Onion Desktop Tools

### Available Languages

- `en-US` - English (US) 🇺🇸
- `it-IT` - Italiano 🇮🇹
- `fr-FR` - Français 🇫🇷
- `es-ES` - Español 🇪🇸
- `de-DE` - Deutsch 🇩🇪

### Demo

To see a demonstration of all languages, run:
```powershell
.\Demo-Language-Feature.ps1
```

### FAQ

**Q: Do I need to regenerate the .exe files to use a different language?**
A: No! The existing .exe files already support all languages.

**Q: How can I verify that the language has been changed?**
A: After modifying `config.json` and restarting the application, all messages will appear in the selected language.

**Q: Can I use .bat files instead of .exe?**
A: Yes! The `_Onion Desktop Tools - Launcher.bat` and `_Onion Desktop Tools - Launcher (With Console).bat` files work exactly like the .exe files and also support all languages.

---

## Technical Details

The launcher architecture:
1. `.exe` or `.bat` launcher → Requests admin privileges
2. Creates directories (backups, downloads/ODT_updates)
3. Calls `ODT_update.ps1` → Checks for updates
4. Calls `Menu.ps1` → Main application with UI
5. `Menu.ps1` loads `Common-Functions.ps1` → Language support

The language system:
- Language files are in `Languages/` directory
- Each file contains 60+ translated strings
- Language is loaded at runtime from config.json
- No compilation or .exe regeneration needed

For more details, see:
- `RECREATING_EXE_FILES.md` (English)
- `RECREATING_EXE_FILES_IT.md` (Italian)
