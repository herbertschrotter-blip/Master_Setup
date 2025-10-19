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

### 2️⃣ System- und Benutzererkennung

Immer als Erstes prüfen, auf welchem System das Modul läuft.

```powershell
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
$sysInfo = Get-SystemInfo
```

### 3️⃣ Dateistruktur laden

```powershell
. "$PSScriptRoot\..\Libs\Lib_ListFiles.ps1"
$projectData = Get-ProjectStructure
```

### 4️⃣ Fehlerbehandlung

```powershell
try {
    # Code
}
catch {
    Write-Host "❌ Fehler: $($_.Exception.Message)" -ForegroundColor Red
}
```

### 5️⃣ DebugMode-System (seit SYS_V1.1.4)

Aktiviert erweiterte Konsolenausgaben und Debug-Logs in allen Modulen.

* `Get-DebugMode` → gibt aktuellen Zustand zurück (`$true` / `$false`)
* `Set-DebugMode -Value $true|$false` → schaltet DebugMode global ein/aus

Bleibt aktiv, bis das Framework beendet wird. Wird nur beim Menüpunkt „Beenden“ deaktiviert.

### 6️⃣ Untermenüs (seit SYS_V1.1.4)

Das Einstellungsmenü (`Menu-Einstellungen.ps1`) erlaubt DebugMode, Systemprüfung, Projektstruktur, Rückkehr.

### 7️⃣ Versions- und Commit-Regeln

* JSON-, Log- und Backup-Dateien nie committen
* Commit immer separat und prägnant

Beispiel:

```
SYS_V1.1.4 – DebugMode-Anzeige im Hauptmenü integriert
```

---

## 🧩 Library-Übersicht

### 🔹 Lib_Json.ps1

* Universelle JSON-Verwaltung
* Enthält `Get-JsonFile`, `Save-JsonFile`, `Add-JsonEntry`
* Automatische Datei-Erstellung, Fehlerhandling

### 🔹 Lib_Systeminfo.ps1

* Erkennung Benutzer, Computer, Pfade
* Verwaltung `Systeminfo.json` & DebugMode
* Funktionen: `Get-SystemInfo`, `Get-DebugMode`, `Set-DebugMode`

### 🔹 Lib_ListFiles.ps1

* Erfasst Projektstruktur
* Funktion: `Get-ProjectStructure [-AsJson]`

### 🔹 Lib_Debug.ps1

* `Write-DebugLog` → Ausgabe nur bei DebugMode
* `Write-DebugFile` → schreibt Log in `04_Logs`

### 🔹 Lib_Menu.ps1

* Zentrale Menülogik für alle Module
* Unterstützt Rückkehr-Logik und Debug-Hinweis

---

## 🧩 Modul-Übersicht

| Modul                  | Libraries                                | Beschreibung                   |
| ---------------------- | ---------------------------------------- | ------------------------------ |
| Master_Controller.ps1  | Lib_Systeminfo, Lib_Debug                | Systemstart, Debug-Anzeige     |
| Add-Baustelle.ps1      | Lib_Systeminfo, Lib_Json, Lib_Debug      | Projektverwaltung, JSON, Debug |
| Menu-Einstellungen.ps1 | Lib_Systeminfo, Lib_ListFiles            | Menülogik, Systemprüfung       |
| Check-System.ps1       | Lib_Systeminfo, Lib_Debug, Lib_ListFiles | Statusanalyse                  |
| Detect-System.ps1      | Lib_Systeminfo, Lib_Debug                | Systemregistrierung            |
| List-Files.ps1         | Lib_ListFiles, Lib_Debug                 | Projektstruktur                |
| Test_Systeminfo.ps1    | Lib_Systeminfo, Lib_Debug                | Funktionstest                  |
| Backup-Monitor.ps1     | Lib_Json, Lib_Debug                      | Projektsicherungen (geplant)   |

---

## 🧠 Zusammenfassung

| Aufgabe                   | Datei / Library                   |
| ------------------------- | --------------------------------- |
| System prüfen             | Lib_Systeminfo.ps1                |
| Struktur abrufen          | Lib_ListFiles.ps1                 |
| DebugMode                 | Lib_Systeminfo.ps1                |
| Debug-Logs                | Lib_Debug.ps1                     |
| Menü                      | Menu-Einstellungen.ps1            |
| Projektstruktur speichern | Projektstruktur.json              |
| Dokumentation             | developer_notes.md, Changelog.txt |

---

Autor: Herbert Schrotter
Stand: 19.10.2025
Framework-Version: SYS_V1.1.6
