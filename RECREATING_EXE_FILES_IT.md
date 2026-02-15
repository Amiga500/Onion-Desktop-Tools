# Ricreare i File Launcher .exe

Questo documento spiega come sono stati ricreati i due file launcher .exe per il progetto Onion Desktop Tools e chiarisce la loro relazione con le nuove funzionalità.

## Informazioni Importanti

**Gli attuali file .exe supportano già tutte le nuove funzionalità!**

I file launcher .exe sono **semplici wrapper** che eseguono le seguenti operazioni:
1. Richiedono privilegi di amministratore
2. Creano le directory necessarie (backups, downloads/ODT_updates)
3. Chiamano `ODT_update.ps1`, che poi chiama `Menu.ps1`

**Tutte le funzionalità dell'applicazione** (supporto multilingua, configurazione, logging, ecc.) sono implementate negli script PowerShell (`Menu.ps1`, `Common-Functions.ps1`, ecc.), **non nei launcher .exe**.

Pertanto:
- ✅ La modifica della lingua funziona con i file .exe esistenti
- ✅ Il supporto multilingua (5 lingue) funziona con i file .exe esistenti
- ✅ Il logging migliorato funziona con i file .exe esistenti
- ✅ Il sistema di configurazione funziona con i file .exe esistenti
- ✅ Tutte le nuove funzionalità funzionano con i file .exe esistenti

## Supporto Multilingua

L'applicazione supporta 5 lingue:
- Inglese (en-US) - Predefinito
- **Italiano (it-IT) - Italiano** 🇮🇹
- Francese (fr-FR) - Français
- Spagnolo (es-ES) - Español
- Tedesco (de-DE) - Deutsch

### Come Cambiare la Lingua

**Non è necessario rigenerare i file .exe per cambiare lingua!**

1. Apri il file `config.json`
2. Trova l'impostazione `"Language"` sotto `"ODT_Settings"` → `"General"`
3. Cambia il valore nel codice della lingua preferita (es. `"it-IT"` per l'italiano)
4. Salva il file e riavvia Onion Desktop Tools

Esempio per impostare l'italiano:
```json
{
  "ODT_Settings": {
    "General": {
      "Language": "it-IT",
      "LogLevel": "Info",
      "EnablePersistentLogging": true,
      ...
    }
  }
}
```

## Altre Nuove Funzionalità Supportate

Tutte queste funzionalità sono **completamente supportate** dai file launcher .exe esistenti senza alcuna modifica:

- ✅ **Supporto multilingua** (5 lingue complete)
- ✅ **Logging persistente** con rotazione giornaliera dei log
- ✅ **Sistema di configurazione** tramite config.json
- ✅ **Miglioramenti della sicurezza** (validazione sicurezza del disco)
- ✅ **Verifica dell'integrità degli strumenti**
- ✅ **Suite di test completa**
- ✅ **Modalità dry-run** per test
- ✅ **Gestione Ctrl+C** per interruzione controllata

**Tutte queste funzionalità funzionano immediatamente** quando si avvia tramite i file .exe, poiché sono implementate negli script PowerShell che i launcher .exe chiamano.

## Quando Rigenerare i File .exe

I file .exe devono essere rigenerati **solo se**:
- La logica del launcher stesso cambia (es. parametri di avvio diversi)
- Vuoi aggiornare l'icona o i metadati
- I template dei file batch vengono modificati

**Non è necessario rigenerare i file .exe per:**
- ❌ Aggiungere supporto per nuove lingue
- ❌ Modificare funzionalità esistenti
- ❌ Aggiungere nuove funzionalità all'applicazione
- ❌ Cambiare la configurazione

## File Sorgente

I file .exe sono generati dai template di file batch:
- `tools/launcher_template_hidden.bat` - Template per versione console nascosta
- `tools/launcher_template_console.bat` - Template per versione console visibile

Questi template includono:
- Controllo elevazione privilegi amministratore
- Configurazione directory (backups, downloads/ODT_updates)
- Funzionalità di auto-aggiornamento tramite ODT_update.ps1

## Come Rigenerare (su Windows)

Se hai bisogno di rigenerare i file .exe su una macchina Windows:

1. Apri `tools/Bat_To_Exe_Converter.exe`
2. Per la versione console nascosta:
   - Carica `tools/launcher_template_hidden.bat`
   - Configura le impostazioni:
     - Titolo: "Onion Desktop Tools"
     - Applicazione invisibile: Sì
     - Privilegi amministratore: Sì
   - Salva come: `Onion Desktop Tools.exe`
3. Per la versione console:
   - Carica `tools/launcher_template_console.bat`
   - Configura le impostazioni:
     - Titolo: "Onion Desktop Tools - With Console"
     - Applicazione invisibile: No
     - Privilegi amministratore: Sì
   - Salva come: `Onion Desktop Tools - WithConsole.exe`

## Metodi di Avvio Alternativi

Gli utenti possono in alternativa usare i file .bat forniti:
- `_Onion Desktop Tools - Launcher.bat` - Console nascosta
- `_Onion Desktop Tools - Launcher (With Console).bat` - Console visibile

Questi file .bat offrono la stessa funzionalità dei file .exe ma potrebbero essere preferiti per evitare avvisi antivirus.

## Note

- **I file .exe supportano automaticamente tutte le nuove funzionalità** perché chiamano gli script PowerShell
- La modifica della lingua, il supporto multilingua, il logging e tutte le altre funzionalità funzionano senza rigenerare i file .exe
- I file .exe sono funzionalmente equivalenti ai launcher .bat
- Entrambi i metodi richiedono privilegi admin ed eseguono l'auto-aggiornamento
- I file .exe potrebbero essere segnalati da alcuni software antivirus (falso positivo)
- I file .bat sono raccomandati per la maggior parte degli utenti in quanto sono più trasparenti e più facili da mantenere
- Per usare una lingua diversa, modifica semplicemente l'impostazione `Language` in `config.json` - non è necessaria la rigenerazione dei file .exe

## Informazioni sui File

1. **Onion Desktop Tools.exe** (97.792 bytes) - Avvia lo strumento con console nascosta
2. **Onion Desktop Tools - WithConsole.exe** (100.352 bytes) - Avvia lo strumento con console visibile

## Strumento di Conversione

Lo strumento `tools/Bat_To_Exe_Converter.exe` viene utilizzato per convertire i file batch in file exe. Questa è un'applicazione GUI Windows che:
- Prende un file .bat come input
- Lo converte in un file .exe autonomo
- Supporta opzioni per visibilità console, personalizzazione icona, ecc.
- Incorpora la logica dello script batch in un eseguibile Windows

**Nota:** Questo è uno strumento solo GUI e richiede una macchina Windows per funzionare.
