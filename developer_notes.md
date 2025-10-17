📘 Datei: 00_MASTER_SETUP\DEVELOPER_NOTES.md
# 🧰 PowerShell Master Setup – Entwickler-Notizen

---

## 🧭 Ziel
Diese Datei beschreibt alle Standards und Vorgehensweisen, um neue Module,
Libraries oder Erweiterungen im PowerShell Master Setup korrekt zu erstellen.
Sie basiert auf dem aktuellen System-Framework (Stand: 17.10.2025).

---

## 📂 Projektstruktur



00_MASTER_SETUP/
├── 00_Info/ ← Changelog, Dokumentation
├── 01_Config/ ← System- und Laufzeitdaten (.json, .txt)
├── 02_Templates/ ← Vorlagen (Excel, Word, CAD usw.)
├── 03_Scripts/
│ ├── Libs/ ← zentrale Bibliotheken
│ │ ├── Lib_Systeminfo.ps1
│ │ └── Lib_ListFiles.ps1
│ └── Modules/ ← eigenständige Module
│ ├── Detect-System.ps1
│ ├── List-Files.ps1
│ └── ...
├── 04_Logs/ ← lokale Logausgaben
└── 05_Backup/ ← Sicherungen


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

2️⃣ System- und Benutzererkennung

Immer als Erstes prüfen, auf welchem System das Modul läuft.
Dadurch werden automatisch Pfade, Benutzer und Umgebungsdaten geladen.

# ------------------------------------------------------------
# 🧠 Systeminformationen laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
$sysInfo = Get-SystemInfo


Die Library Lib_Systeminfo.ps1 prüft:

ob 01_Config\Systeminfo.json existiert,

lädt oder erstellt sie automatisch über Detect-System.ps1,

gibt ein Objekt $sysInfo zurück mit:

$sysInfo.Benutzername

$sysInfo.Computername

$sysInfo.System

$sysInfo.Systempfade.*

3️⃣ Dateistruktur laden (falls benötigt)

Wenn ein Modul auf Dateien oder Verzeichnisse zugreift,
immer über die Library Lib_ListFiles.ps1:

# ------------------------------------------------------------
# 🧾 Projektstruktur laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_ListFiles.ps1"
$projectData = Get-ProjectStructure


Dadurch werden automatisch alle Ordner und Dateien erfasst
und können mit $projectData.Dateien oder $projectData.Ordner
gefiltert oder weiterverarbeitet werden.

4️⃣ Fehlerbehandlung

Alle kritischen Bereiche in try/catch-Blöcken kapseln.
Fehlermeldungen immer klar ausgeben:

try {
    # Code
}
catch {
    Write-Host "❌ Fehler: $($_.Exception.Message)" -ForegroundColor Red
}

5️⃣ Versions- und Commit-Regeln

JSON-, Log- und Backup-Dateien nie committen (stehen in .gitignore)

Nur Skripte, Libraries, README und .gitignore in Git aufnehmen

Commit-Nachricht immer mit Modul und Version:

MOD_V1.2.0 – List-Files.ps1 erweitert: Systemerkennung integriert

🧩 Library-Übersicht
🔹 Lib_Systeminfo.ps1

Zentrale Komponente zur Erkennung von Benutzer und System.

Funktionen:

Get-SystemInfo

prüft und lädt Systeminfo.json

ruft bei Bedarf automatisch Detect-System.ps1 auf

gibt ein Objekt mit allen Systemdaten zurück

Beispiel:

$sysInfo = Get-SystemInfo
Write-Host "🧭 Aktives System: $($sysInfo.Computername)"
Write-Host "👤 Benutzer: $($sysInfo.Benutzername)"


Erzeugte Datei:
01_Config\Systeminfo.json

{
  "Systeme": [
    {
      "Benutzername": "herbert",
      "Computername": "HP-ZBOOK",
      "System": "Microsoft Windows 11 Pro",
      "Systempfade": {
        "RootPath": "D:\\OneDrive\\Dokumente\\02 Arbeit\\05 Vorlagen - Scripte\\00_MASTER_SETUP",
        "ConfigPath": "...",
        "LogPath": "...",
        ...
      }
    }
  ]
}

🔹 Lib_ListFiles.ps1

Erfasst Ordner- und Dateistrukturen des Master-Setups
auf Basis der in Lib_Systeminfo erkannten Pfade.

Hauptfunktion:

Get-ProjectStructure [-AsJson]


Optionen:

Ohne Parameter → gibt Objekt mit Listen zurück

Mit -AsJson → speichert zusätzlich 01_Config\Projektstruktur.json

🧱 Versionsverwaltung & Commit-Regeln

Immer folgende Schritte befolgen:

Code testen (PowerShell-Konsole oder VS Code F5)

Nur funktionierende Versionen committen

Kurze, prägnante Commit-Nachricht:

SYS_V1.1.0 – Systemerkennung beim Start integriert


git push nach erfolgreichem Commit

📓 Changelog / Historie

Alle Änderungen zusätzlich in:

00_Info\Changelog.txt


Format:

[Datum] [Version] – Beschreibung

🧠 Zusammenfassung
Aufgabe	Datei / Library
System prüfen	Lib_Systeminfo.ps1
Dateistruktur abrufen	Lib_ListFiles.ps1
Pfade und Benutzer nutzen	$sysInfo.Systempfade.*
Projektstruktur als JSON speichern	Projektstruktur.json
Lokale Daten (JSON, Logs, Backups)	nicht committen
Dokumentation & Änderungen	DEVELOPER_NOTES.md, Changelog.txt

Stand: 17.10.2025
Autor: Herbert Schrotter
Framework-Version: SYS_V1.1.0