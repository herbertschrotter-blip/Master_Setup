# 🛠️ PowerShell Master Setup – Entwickler-Notizen

---

## 🌍 Ziel

Diese Datei beschreibt alle Standards und Vorgehensweisen, um neue Module, Libraries oder Erweiterungen im PowerShell Master Setup korrekt zu erstellen.
Sie basiert auf dem aktuellen System-Framework (Stand: 18.10.2025).

---

## 🗂️ Projektstruktur

Die Struktur deiner JSON-Ausgabe zeigt alle relevanten Dateien und Ordner deines Projekts korrekt an. Das Schema deckt sich mit dieser Struktur, also passt sie – sie spiegelt das aktuelle Setup realistisch wider.

```plaintext
00_MASTER_SETUP/
├── .vscode/ ← Editor-Einstellungen (launch.json etc.)
│ └── launch.json
├── .gitignore ← Git-Ausschlussregeln
├── 00_Info/ ← Changelog, Dokumentation
├── 01_Config/ ← System- und Laufzeitdaten (.json, .txt)
│ ├── Projektstruktur.json
│ └── Systeminfo.json
├── 02_Templates/ ← Vorlagen (Excel, Word, CAD usw.)
├── 03_Scripts/
│ ├── Libs/ ← zentrale Bibliotheken
│ │ ├── Lib_Systeminfo.ps1
│ │ ├── Lib_ListFiles.ps1
│ │ ├── Lib_Debug.ps1
│ │ ├── Lib_Json.ps1
│ │ └── Lib_Menu.ps1
│ └── Modules/ ← eigenständige Module
│ ├── Add-Baustelle.ps1
│ ├── Backup-Monitor.ps1
│ ├── Check-System.ps1
│ ├── Detect-System.ps1
│ ├── List-Files.ps1
│ ├── Menu-Einstellungen.ps1
│ ├── Show-Logs.ps1
│ ├── Test_Systeminfo.ps1
│ ├── Toggle-Debug.ps1
│ └── Update-Vorlagen.ps1
├── 04_Logs/ ← lokale Logausgaben (nicht committen)
├── 05_Backup/ ← Sicherungen (nicht committen)
├── developer_notes.md ← Entwickler-Dokumentation (diese Datei)
├── Master_Controller.ps1 ← Zentrale Steuerung (Hauptmenü)
├── README.md ← Überblick und Kurzbeschreibung
└── Start_MasterSetup.cmd ← Startdatei (öffnet Master_Controller über CMD)
```

---

## ⚙️ Standard-Aufbau neuer Module

### 1️⃣ Kopfbereich

Jedes Modul beginnt mit einem dokumentierten Header:

```powershell
# ============================================================
# Modul: Modulname.ps1
# Version: MOD_Vx.x.x
# Zweck:   Kurzbeschreibung
# Autor:   Herbert Schrotter
# Datum:   TT.MM.JJJJ
# ============================================================
```

---

### 2️⃣ System- und Benutzererkennung

Immer als Erstes prüfen, auf welchem System das Modul läuft. Dadurch werden automatisch Pfade, Benutzer und Umgebungsdaten geladen.

```powershell
# ------------------------------------------------------------
# 🧠 Systeminformationen laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
$sysInfo = Get-SystemInfo
```

Die **Lib_Systeminfo.ps1** prüft:

* ob `01_Config\Systeminfo.json` existiert
* lädt oder erstellt sie automatisch über `Detect-System.ps1`
* gibt ein Objekt `$sysInfo` zurück mit:

  * `$sysInfo.Benutzername`
  * `$sysInfo.Computername`
  * `$sysInfo.System`
  * `$sysInfo.Systempfade.*`
  * `$sysInfo.DebugMode`

---

### 3️⃣ Dateistruktur laden (falls benötigt)

```powershell
# ------------------------------------------------------------
# 🧾 Projektstruktur laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_ListFiles.ps1"
$projectData = Get-ProjectStructure
```

Dadurch werden automatisch alle Ordner und Dateien erfasst und können mit `$projectData.Dateien` oder `$projectData.Ordner` gefiltert werden.

---

### 4️⃣ Fehlerbehandlung

Alle kritischen Bereiche in `try/catch`-Blöcken kapseln.

```powershell
try {
    # Code
}
catch {
    Write-Host "❌ Fehler: $($_.Exception.Message)" -ForegroundColor Red
}
```

---

### 5️⃣ DebugMode-System (seit SYS_V1.1.4)

Der DebugMode ist eine globale Einstellung in `01_Config\Systeminfo.json`.

**Zweck:**
Aktiviert erweiterte Konsolenausgaben und Debug-Logs in allen Modulen.

**Verwaltung:**
Über Funktionen in `Lib_Systeminfo.ps1`:

* `Get-DebugMode` → gibt aktuellen Zustand zurück (`$true` / `$false`)
* `Set-DebugMode -Value $true|$false` → schaltet DebugMode global ein/aus

**Eigenschaften:**

* bleibt aktiv, bis das Framework beendet wird
* wird **nur beim Menüpunkt „Beenden“** automatisch auf `false` gesetzt
* zeigt in allen Menüs den Hinweis `🪲 DEBUG-MODE AKTIVIERT`

---

### 6️⃣ Untermenüs (seit SYS_V1.1.4)

Das Einstellungsmenü (`Menu-Einstellungen.ps1`) erlaubt:

* DebugMode an/aus
* Systemprüfung starten
* Projektstruktur auflisten
* Rückkehr zum Hauptmenü

```powershell
"5" { & "$PSScriptRoot\03_Scripts\Modules\Menu-Einstellungen.ps1" }
```

Nach Verlassen wird automatisch der Master_Controller erneut gestartet.

---

### 7️⃣ Versions- und Commit-Regeln

* JSON-, Log- und Backup-Dateien **nie committen** (`.gitignore`)
* Nur Skripte, Libraries, README, Changelogs und Developer Notes versionieren
* Commit immer separat angeben (nicht im Codeblock)

**Beispiele:**

```
SYS_V1.1.4 – DebugMode-Anzeige im Hauptmenü integriert; Deaktivierung nur bei Beenden
MENU_V1.0.3 – Menüpunkt „Projektstruktur auflisten“ (List-Files) hinzugefügt
LIB_V1.2.4 – Set-DebugMode korrigiert: legt DebugMode automatisch an, falls in Systeminfo.json fehlt
```

---

## 🧩 Library-Übersicht

### 🔹 Lib_Json.ps1

* Universelle JSON-Verwaltungsbibliothek
* Dient zum Einlesen, Speichern und Aktualisieren beliebiger JSON-Dateien im gesamten Framework
* Enthält Funktionen `Get-JsonFile`, `Save-JsonFile`, `Add-JsonEntry`
* Unterstützt automatisches Anlegen von Dateien und sichere Fehlerbehandlung
* Wird aktuell primär in `Add-Baustelle.ps1` eingesetzt, künftig globale Verwendung in allen Modulen geplant

### 🔹 Lib_Systeminfo.ps1

* Erkennung von Benutzer, Computer, Systempfaden
* Automatische Erstellung von `Systeminfo.json`
* Verwaltung des globalen DebugMode
* Schnittstelle zu `Detect-System.ps1`

Funktionen:

* `Get-SystemInfo`
* `Get-DebugMode`
* `Set-DebugMode`

---

### 🔹 Lib_ListFiles.ps1

* Erfasst Ordner- und Dateistrukturen des Master-Setups
* Optional Speicherung als `Projektstruktur.json`

Hauptfunktion:

* `Get-ProjectStructure [-AsJson]`

---

### 🔹 Lib_Debug.ps1

* Zentrale Debug-Ausgabe- und Logging-Funktionen
* `Write-DebugLog "Text"` → gibt Meldung nur bei aktivem DebugMode aus
* `Write-DebugFile "Text"` → schreibt zusätzlich in `04_Logs\Debug_YYYY-MM-DD_HH-mm-ss.log`
* Eine Logdatei pro Sitzung mit Zeitstempel
* Automatische Sitzungsverwaltung mit Start-Header

---

### 🔹 Lib_Menu.ps1

* Zentrale Menülogik für alle Module
* Unterstützt Show-SubMenu mit Parameter -ReturnAfterAction
* Sortiert Menüoptionen numerisch/alphabetisch
* Globale Beenden-Funktion über Eingabe X
* Zeigt Debug-Hinweis nur, wenn aktiv

---

## 🧩 Modul-Übersicht

### 🔹 Add-Baustelle.ps1

* Modul zur Verwaltung von Projekten (Baustellen)
* Verwendet systemunabhängige JSON-Struktur mit `Lib_Json.ps1`
* Integriert **Statussystem** (Aktiv / Abgeschlossen) und Menüführung mit Rückkehrmöglichkeit
* Ausgabe in konsolengerechter **ASCII-Tabelle** (Name, Status, Datum)
* Künftige Erweiterungen: Projekt löschen, archivieren, filtern, Sync mit OneDrive

### 🔹 Master_Controller.ps1

* Startpunkt für alle Module
* Zeigt Debug-Hinweis bei Aktivierung
* Deaktiviert DebugMode nur beim „Beenden“

### 🔹 Menu-Einstellungen.ps1

* DebugMode umschalten
* Systemprüfung
* Projektstruktur auflisten
* Rückkehr zum Hauptmenü

### 🔹 Check-System.ps1

* Kontrolle der Hauptordnerstruktur
* Prüft `Systeminfo.json` und `Projektstruktur.json`
* Gibt Statusberichte im Konsolenstil aus

### 🔹 Detect-System.ps1

* Erstellt automatisch `Systeminfo.json`
* Erkennt Benutzername, Computername, Systempfade
* Schreibt bei aktivem DebugMode detaillierte Logs

### 🔹 List-Files.ps1

* Erstellt Übersicht aller Dateien & Ordner im Projekt
* Nutzt `Lib_ListFiles.ps1`
* Kann optional `Projektstruktur.json` erzeugen

### 🔹 Test_Systeminfo.ps1

* Testet `Get-SystemInfo`, `Set-DebugMode`
* Prüft Schreib-/Lesezugriff auf `Systeminfo.json`

### 🔹 Start_MasterSetup.cmd

```cmd
powershell.exe -ExecutionPolicy Bypass -File ".\Master_Controller.ps1"
```

---

## 🔗 Modul-Library-Beziehungen

| Modul / Datei              | Verwendete Libraries                     | Beschreibung der Zusammenarbeit                       |
| -------------------------- | ---------------------------------------- | ----------------------------------------------------- |
| **Master_Controller.ps1**  | Lib_Systeminfo, Lib_Debug                | Systeminitialisierung, DebugMode-Anzeige              |
| **Add-Baustelle.ps1**      | Lib_Systeminfo, Lib_Json, Lib_Debug      | JSON-Verwaltung, Benutzer-/Systeminfo, Debug-Ausgaben |
| **Menu-Einstellungen.ps1** | Lib_Systeminfo, Lib_ListFiles            | Menülogik, System- und Strukturprüfung                |
| **Check-System.ps1**       | Lib_Systeminfo, Lib_Debug, Lib_ListFiles | Systemstatusanalyse, Ausgabeprotokoll                 |
| **Detect-System.ps1**      | Lib_Systeminfo, Lib_Debug                | Automatische Systemregistrierung                      |
| **List-Files.ps1**         | Lib_ListFiles, Lib_Debug                 | Projektstruktur erfassen und ausgeben                 |
| **Test_Systeminfo.ps1**    | Lib_Systeminfo, Lib_Debug                | Funktionstest der Systemerkennung                     |
| **Backup-Monitor.ps1**     | Lib_Json, Lib_Debug                      | Geplante Integration für Projektsicherungen           |

Diese Übersicht zeigt die aktuelle Zuordnung der Module zu ihren Bibliotheken. Sie dient als Orientierung für zukünftige Erweiterungen, um Abhängigkeiten klar zu dokumentieren.

---

## 🧱 Versionsverwaltung

Wenn neue Libraries oder Module entstehen, füge sie auch hier in die Dokumentation der jeweiligen Abschnitte hinzu, damit die Übersicht aktuell bleibt. & Commit-Regeln

1️⃣ Code testen (PowerShell-Konsole oder VS Code)
2️⃣ Nur funktionierende Versionen committen
3️⃣ Commit-Nachricht immer prägnant
4️⃣ Nie JSON-, Log-, Backup-Dateien committen

---

## 📓 Changelog / Historie

Alle Änderungen zusätzlich in `00_Info\Changelog.txt`

Format:

```
[Datum] [Version] – Beschreibung
```

---

## 🧠 Zusammenfassung

| Aufgabe                            | Datei / Library                   |
| ---------------------------------- | --------------------------------- |
| System prüfen                      | Lib_Systeminfo.ps1                |
| Dateistruktur abrufen              | Lib_ListFiles.ps1                 |
| DebugMode verwalten                | Lib_Systeminfo.ps1                |
| Debug-Logs (optional)              | Lib_Debug.ps1                     |
| Einstellungen-Menü                 | Menu-Einstellungen.ps1            |
| Systemprüfung                      | Check-System.ps1                  |
| Pfade und Benutzer nutzen          | $sysInfo.Systempfade.*            |
| Projektstruktur speichern          | Projektstruktur.json              |
| Lokale Daten (JSON, Logs, Backups) | nicht committen                   |
| Dokumentation & Änderungen         | DEVELOPER_NOTES.md, Changelog.txt |

---

## 🔧 Ergänzungen (18.10.2025)

### 🏗️ Modul: Add-Baustelle.ps1 – Version MOD_V1.1.1

* Neues, **systemunabhängiges JSON-Modell**: Zentrale Projektliste (`Projekte`) mit Unterobjekt `Info` (Benutzer, Computer, Pfad)
* Ausgabeformat verbessert: **ASCII-Tabelle** mit fester Spaltenbreite, Datum ohne Uhrzeit
* **Statusverwaltung integriert** (Aktiv / Abgeschlossen)
* **Menüstruktur überarbeitet**: Hauptmenü mit Status-Zusammenfassung (aktive / abgeschlossene Projekte)
* **DebugMode-Anzeige** integriert (via `Lib_Systeminfo.ps1`)

---

### 📘 Lib_Json.ps1

* Neue Bibliothek zur JSON-Verwaltung (`Get-JsonFile`, `Save-JsonFile`, `Add-JsonEntry`)
* Wird aktuell nur in `Add-Baustelle.ps1` eingesetzt
* Weitere Module (`Check-System.ps1`, `Backup-Monitor.ps1`, `List-Files.ps1` etc.) müssen noch angepasst werden, um `Lib_Json` zu nutzen
* Geplante Erweiterungen:

  * Globale Integration in alle Module
  * Automatische Backup-Erstellung vor jedem Schreibvorgang
  * Fehlerbehandlung bei beschädigten oder leeren JSON-Dateien

---

🧭 System- und Menü-Stabilisierung – Oktober 2025
🔹 Ziel

Nach dem Zurücksetzen auf Commit dd5746e wurde das gesamte PowerShell Master Setup-System stabilisiert, das Menüsystem vereinheitlicht und die Modulstruktur optimiert.

⚙️ Änderungen im Detail

Lib_Menu.ps1 (LIB_V1.0.5) – X-Beenden, sortierte Ausgabe, ReturnAfterAction

Menu-Einstellungen.ps1 (MENU_V1.0.4) – Nutzung zentraler Menülogik

Master_Controller.ps1 (SYS_V1.1.6) – Beenden über X, DebugMode-Off nur beim Exit

Add-Baustelle.ps1 (MOD_V1.1.3) – Funktionsreihenfolge korrigiert, Live-Status

---

### 🧱 Erweiterungen für Add-Baustelle (geplant)

* 🔹 **Projekt löschen** mit Sicherheitsabfrage
* 🔹 **Projekt archivieren / wiederherstellen**
* 🔹 **Projekte filtern / durchsuchen** nach Name, Datum oder Status
* 🔹 **Automatische Sicherung / OneDrive-Sync** der Projektliste
* 🔹 **Integration mit Add-BaustelleOrdner.ps1** für Ordnererstellung beim Anlegen
* 🔹 **Migration alter JSON-Strukturen** (Benutzer/Computer-Verschachtelung → neues Format)
* 🔹 **Optionale Statushistorie** (Statusänderungen mit Datum)

---

### 🏢 Geplanter „Firmenmodus“ (Systemkompatibilität)

**Ziel:**
Das Master Setup automatisch an eingeschränkte Firmenumgebungen anpassen (z. B. ExecutionPolicy, Schreibrechte, OneDrive-Richtlinien).

**Funktionen (geplant):**

* 🔹 Automatische Erkennung von restriktiven PowerShell-Richtlinien
  → Wechsel in *Read-Only-Modus*, wenn Skriptausführung blockiert
* 🔹 Prüfung auf Schreibrechte im Projektverzeichnis
  → ggf. Umleitung in `%USERPROFILE%\Documents\Master_Setup`
* 🔹 Optionale Verwendung einer portablen PowerShell-7-Instanz
  → Start über `.\pwsh\pwsh.exe -ExecutionPolicy Bypass`
* 🔹 Anzeige einer Warnung bei eingeschränkter Umgebung (z. B. „Firmenmodus aktiv“)
* 🔹 Zentrale Steuerung über `Lib_Systeminfo.ps1`
  → `Detect-System.ps1` erkennt „Firmenmodus“ automatisch und setzt Flag `$sysInfo.Firmenmodus = $true`

**Spätere Integration:**

* Im Hauptmenü (`Master_Controller.ps1`) optional Anzeige:

  ```powershell
  if ($sysInfo.Firmenmodus) {
      Write-Host '🏢 Firmenmodus aktiv (eingeschränkte Umgebung)' -ForegroundColor DarkYellow
  }
  ```

**Vorteil:**
Das gesamte Framework bleibt **voll funktionsfähig**, selbst wenn PowerShell auf Firmenrechnern stark reglementiert ist.

---

### 💾 Commit-Format

(Standard)

```
[YYYY-MM-DD] MOD_Vx.x.x – Kurze Beschreibung
• Punkt 1
• Punkt 2
• Punkt 3
```

---

### 🧠 Merke

* Commit-Format exakt beibehalten
* Menü in `Add-Baustelle.ps1` so anpassen, dass Rückkehr zum Menü nach jeder Aktion möglich ist
* `Lib_Json.ps1` aktuell nur in Add-Baustelle genutzt → Integration in weitere Module geplant
* Erweiterungen für Add-Baustelle vorbereiten (Löschen, Archivieren, Filtern, Migration, Sync)

---

Autor: Herbert Schrotter
Stand: 19.10.2025
Framework-Version: SYS_V1.1.6
