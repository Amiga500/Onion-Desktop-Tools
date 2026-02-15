# Lista di Verifica File EXE

Questa lista di controllo aiuta a verificare che i file launcher .exe siano configurati e funzionanti correttamente.

## Controllo Rapido: Il Tuo File .exe è Corretto?

### Sintomi del Problema:
- ❌ Il titolo della finestra mostra testo senza spazi (es. "OnionDesktopTools")
- ❌ La finestra della console mostra testo in inglese anche quando è configurato l'italiano
- ❌ L'applicazione non si avvia o si blocca immediatamente

### Soluzione Rapida:
**Usa invece i file launcher .bat!** Funzionano in modo identico e non hanno problemi di formattazione del titolo:
- `_Onion Desktop Tools - Launcher.bat` (console nascosta)
- `_Onion Desktop Tools - Launcher (With Console).bat` (console visibile)

## Processo di Verifica Completo

### Passo 1: Ispezione Visiva

1. **Controllo Dimensione File**:
   - `Onion Desktop Tools.exe` dovrebbe essere circa 97-98 KB
   - `Onion Desktop Tools - WithConsole.exe` dovrebbe essere circa 100-101 KB

2. **Test di Avvio**:
   - Fai doppio clic su `Onion Desktop Tools - WithConsole.exe`
   - Il titolo della finestra della console dovrebbe dire: **"Onion Desktop Tools - With Console"** (con spazi)
   - L'interfaccia GUI PowerShell dovrebbe apparire nella lingua configurata

3. **Test Lingua**:
   - Imposta `"Language": "it-IT"` in `config.json`
   - Avvia l'applicazione
   - L'interfaccia GUI PowerShell dovrebbe essere visualizzata in italiano
   - Nota: Il titolo della finestra della console sarà sempre in inglese (incorporato nel .exe)

### Passo 2: Problemi Comuni e Soluzioni

#### Problema 1: Titolo Senza Spazi
**Sintomo**: La finestra mostra "OnionDesktopTools" o simile senza spazi

**Causa**: Il file .exe è stato creato con il campo titolo errato in Bat_To_Exe_Converter

**Soluzione**: Rigenera il file .exe seguendo questi passaggi esatti:

1. Apri `tools/Bat_To_Exe_Converter.exe` su una macchina Windows
2. Carica il file template appropriato
3. **CRITICO**: Nel campo "Title" o "Window Name", inserisci:
   - Per versione nascosta: `Onion Desktop Tools` (con spazi!)
   - Per versione console: `Onion Desktop Tools - With Console` (con spazi!)
4. Seleziona l'opzione "Administrator privileges"
5. Imposta "Invisible application" correttamente (Sì per nascosta, No per console)
6. Compila e salva

#### Problema 2: L'Applicazione Non Si Avvia
**Sintomo**: Facendo doppio clic sul file .exe non succede nulla o mostra un errore

**Possibili Cause**:
- Script PowerShell mancanti (Menu.ps1, ODT_update.ps1)
- Directory di lavoro non corretta
- Permessi insufficienti
- Antivirus che blocca l'esecuzione

**Soluzione**:
1. Assicurati che tutti i file .ps1 siano nella stessa directory del file .exe
2. Fai clic destro sul file .exe → "Esegui come amministratore"
3. Controlla i log dell'antivirus e aggiungi un'eccezione se necessario
4. Prova a usare i file launcher .bat invece

#### Problema 3: La Lingua Non Funziona
**Sintomo**: L'interfaccia GUI mostra l'inglese nonostante l'italiano in config.json

**Diagnosi**:
1. Controlla che `config.json` abbia il formato corretto:
   ```json
   {
     "ODT_Settings": {
       "General": {
         "Language": "it-IT"
       }
     }
   }
   ```
2. Verifica che `Languages/it-IT.json` esista
3. Controlla gli errori nell'output della console (usa la versione WithConsole)

**Nota**: Il titolo della finestra della console dal file .exe è sempre incorporato e non cambierà con le impostazioni della lingua. Questo è normale e previsto.

### Passo 3: Istruzioni per la Rigenerazione (se necessario)

Se la verifica fallisce, rigenera i file .exe:

**Vedi istruzioni dettagliate in**:
- [RECREATING_EXE_FILES.md](RECREATING_EXE_FILES.md) - Inglese
- [RECREATING_EXE_FILES_IT.md](RECREATING_EXE_FILES_IT.md) - Italiano

**Punti Chiave**:
- ✅ Usa il titolo esatto: `Onion Desktop Tools` (con spazi)
- ✅ Abilita "Administrator privileges"
- ✅ Imposta "Invisible application" correttamente
- ✅ Usa il file template corretto
- ✅ Testa dopo la creazione

### Passo 4: Soluzione Alternativa

**Raccomandato**: Usa i file launcher .bat invece dei file .exe:

**Vantaggi dei launcher .bat**:
- ✅ Più trasparenti (puoi leggere il codice)
- ✅ Meno probabilità di attivare l'antivirus
- ✅ Più facili da modificare se necessario
- ✅ Nessun problema di formattazione del titolo
- ✅ Funzionalmente identici ai file .exe

**File**:
- `_Onion Desktop Tools - Launcher.bat` (console nascosta)
- `_Onion Desktop Tools - Launcher (With Console).bat` (console visibile)

## Riepilogo

### Funziona Correttamente?
- ✅ Il titolo della console ha una spaziatura corretta
- ✅ L'interfaccia GUI viene visualizzata nella lingua configurata
- ✅ Tutte le funzionalità funzionano normalmente
→ **Nessuna azione necessaria**

### Hai Problemi?
- ❌ Titolo senza spazi
- ❌ La lingua non funziona
- ❌ Non si avvia
→ **Usa i launcher .bat OPPURE rigenera i file .exe**

## Supporto

Per ulteriore aiuto:
- Leggi [README.md](README.md) per l'uso generale
- Controlla [RECREATING_EXE_FILES_IT.md](RECREATING_EXE_FILES_IT.md) per la creazione dei file .exe
- Vedi [LANGUAGE_GUIDE.md](LANGUAGE_GUIDE.md) per la configurazione della lingua
- Rivedi [CODE_REVIEW.md](CODE_REVIEW.md) per i dettagli tecnici

## Riferimento Rapido

| File | Scopo | Console | Admin |
|------|-------|---------|-------|
| `Onion Desktop Tools.exe` | Avvio con console nascosta | Nascosta | Sì |
| `Onion Desktop Tools - WithConsole.exe` | Avvio con console visibile | Visibile | Sì |
| `_Onion Desktop Tools - Launcher.bat` | Avvio con console nascosta | Nascosta | Sì |
| `_Onion Desktop Tools - Launcher (With Console).bat` | Avvio con console visibile | Visibile | Sì |

**Tutte e quattro le opzioni sono funzionalmente equivalenti** - scegli in base alle preferenze.
