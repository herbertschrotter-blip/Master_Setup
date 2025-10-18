🧰 PowerShell Master Setup – Entwickler-Notizen
🧭 Ziel

Diese Datei beschreibt alle Standards und Vorgehensweisen, um neue Module,
Libraries oder Erweiterungen im PowerShell Master Setup korrekt zu erstellen.
Sie basiert auf dem aktuellen System-Framework (Stand: 18.10.2025).

📂 Projektstruktur
00_MASTER_SETUP/
├── .vscode/                     ← Editor-Einstellungen (launch.json etc.)
│   └── launch.json
├── .gitignore                   ← Git-Ausschlussregeln
├── 00_Info/                     ← Changelog, Dokumentation
├── 01_Config/                   ← System- und Laufzeitdaten (.json, .txt)
│   ├── Projektstruktur.json
│   └── Systeminfo.json
├── 02_Templates/                ← Vorlagen (Excel, Word, CAD usw.)
├── 03_Scripts/
│   ├── Libs/                    ← zentrale Bibliotheken
│   │   ├── Lib_Systeminfo.ps1
│   │   ├── Lib_ListFiles.ps1
│   │   └── (geplant) Lib_Debug.ps1
│   └── Modules/                 ← eigenständige Module
│       ├── Add-Baustelle.ps1
│       ├── Backup-Monitor.ps1
│       ├── Check-System.ps1
│       ├── Detect-System.ps1
│       ├── List-Files.ps1
│       ├── Menu-Einstellungen.ps1
│       ├── Show-Logs.ps1
│       ├── Test_Systeminfo.ps1
│       └── Update-Vorlagen.ps1
├── 04_Logs/                     ← lokale Logausgaben (nicht committen)
├── 05_Backup/                   ← Sicherungen (nicht committen)
├── developer_notes.md            ← Entwickler-Dokumentation (diese Datei)
├── Master_Controller.ps1         ← Zentrale Steuerung (Hauptmenü)
├── README.md                     ← Überblick und Kurzbeschreibung
└── Start_MasterSetup.cmd         ← Startdatei (öffnet Master_Controller über CMD)

⚙️ Standard-Aufbau neuer Module
1️⃣ Kopfbereich

Jedes Modul beginnt mit einem dokumentierten Header:

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


Lib_Systeminfo.ps1 prüft:

ob 01_Config\Systeminfo.json existiert

lädt oder erstellt sie automatisch über Detect-System.ps1

gibt ein Objekt $sysInfo zurück mit:

$sysInfo.Benutzername

$sysInfo.Computername

$sysInfo.System

$sysInfo.Systempfade.*

$sysInfo.DebugMode

3️⃣ Dateistruktur laden (falls benötigt)
# ------------------------------------------------------------
# 🧾 Projektstruktur laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_ListFiles.ps1"
$projectData = Get-ProjectStructure


Damit werden automatisch alle Ordner und Dateien erfasst
und können mit $projectData.Dateien oder $projectData.Ordner gefiltert werden.

4️⃣ Fehlerbehandlung

Alle kritischen Bereiche in try/catch-Blöcken kapseln.

try {
    # Code
}
catch {
    Write-Host "❌ Fehler: $($_.Exception.Message)" -ForegroundColor Red
}

5️⃣ DebugMode-System (seit SYS_V1.1.4)

Der DebugMode ist eine globale Einstellung in 01_Config\Systeminfo.json.

Zweck:
Aktiviert erweiterte Konsolenausgaben und Debug-Logs in allen Modulen.

Verwaltung:
Über Funktionen in Lib_Systeminfo.ps1:

Get-DebugMode → gibt aktuellen Zustand zurück ($true / $false)

Set-DebugMode -Value $true|$false → schaltet DebugMode global ein/aus

Eigenschaften:

bleibt aktiv, bis das Framework beendet wird

wird nur beim Menüpunkt „Beenden“ automatisch auf false gesetzt

zeigt in allen Menüs den Hinweis 🪲 DEBUG-MODE AKTIVIERT

Beispiel:

if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
}


Beispielhafte Systeminfo.json mit DebugMode:

{
  "DebugMode": true,
  "Systeme": [
    {
      "Benutzername": "herbe",
      "Computername": "DESKTOP-PC",
      "System": "Microsoft Windows 11 Pro",
      "Systempfade": {
        "RootPath": "D:\\OneDrive\\Dokumente\\02 Arbeit\\05 Vorlagen - Scripte\\00_Master_Setup"
      }
    }
  ]
}

6️⃣ Untermenüs (seit SYS_V1.1.4)

Das Einstellungsmenü (Menu-Einstellungen.ps1) erlaubt:

DebugMode an/aus

Systemprüfung starten

Projektstruktur auflisten

Rückkehr zum Hauptmenü

"5" { & "$PSScriptRoot\03_Scripts\Modules\Menu-Einstellungen.ps1" }


Nach Verlassen wird automatisch der Master_Controller erneut gestartet.

7️⃣ Versions- und Commit-Regeln

JSON-, Log- und Backup-Dateien nie committen (.gitignore)

Nur Skripte, Libraries, README, Changelogs und Developer Notes versionieren

Commit immer separat angeben (nicht im Codeblock)

Beispiele:

SYS_V1.1.4 – DebugMode-Anzeige im Hauptmenü integriert; Deaktivierung nur bei Beenden
MENU_V1.0.3 – Menüpunkt „Projektstruktur auflisten“ (List-Files) hinzugefügt
LIB_V1.2.4 – Set-DebugMode korrigiert: legt DebugMode automatisch an, falls in Systeminfo.json fehlt

🧩 Library-Übersicht
🔹 Lib_Systeminfo.ps1

Erkennung von Benutzer, Computer, Systempfaden

Automatische Erstellung von Systeminfo.json

Verwaltung des globalen DebugMode

Schnittstelle zu Detect-System.ps1

Funktionen:

Get-SystemInfo

Get-DebugMode

Set-DebugMode

🔹 Lib_ListFiles.ps1

Erfasst Ordner- und Dateistrukturen des Master-Setups

Optional Speicherung als Projektstruktur.json

Hauptfunktion:

Get-ProjectStructure [-AsJson]

🔹 Lib_Debug.ps1 (optional, ab SYS_V1.4 geplant)

Zentrale Debug-Ausgabe- und Logging-Funktionen

Write-DebugLog "Text" → gibt Meldung nur bei aktivem DebugMode aus

Write-DebugFile "Text" → schreibt zusätzlich in 04_Logs\Debug.log

🧩 Modul-Übersicht
🔹 Master_Controller.ps1

Hauptmenü des Systems.

Startpunkt für alle Module

Zeigt Debug-Hinweis bei Aktivierung

Deaktiviert DebugMode nur beim „Beenden“

🔹 Menu-Einstellungen.ps1

Untermenü für:

DebugMode umschalten

Systemprüfung

Projektstruktur auflisten

Rückkehr zum Hauptmenü

🔹 Check-System.ps1

Prüft Systemstatus und Setup-Integrität:

Kontrolle der Hauptordnerstruktur

Prüft Systeminfo.json und Projektstruktur.json

Gibt Statusberichte im Konsolenstil aus

🔹 Detect-System.ps1

Wird automatisch gestartet, wenn Systeminfo.json fehlt.

erkennt Benutzername, Computername, Systempfade

erzeugt neue Systeminfo.json

🔹 List-Files.ps1

Erstellt eine vollständige Übersicht aller Ordner und Dateien im Projekt.

nutzt Lib_ListFiles.ps1

kann optional JSON-Datei Projektstruktur.json erzeugen

wird auch über Einstellungsmenü aufgerufen

🔹 Test_Systeminfo.ps1

Internes Testmodul zur Überprüfung von:

Get-SystemInfo

Set-DebugMode

Schreib-/Lesezugriff auf Systeminfo.json
Wird nur für Debug- und Entwicklungszwecke verwendet.

🔹 Start_MasterSetup.cmd

Batch-Datei zum schnellen Start des Systems ohne PowerShell-IDE.
Startet Master_Controller.ps1 über PowerShell-Konsole:

powershell.exe -ExecutionPolicy Bypass -File ".\Master_Controller.ps1"

🧱 Versionsverwaltung & Commit-Regeln

1️⃣ Code testen (PowerShell-Konsole oder VS Code)
2️⃣ Nur funktionierende Versionen committen
3️⃣ Commit-Nachricht immer prägnant
4️⃣ Nie JSON-, Log-, Backup-Dateien committen

📓 Changelog / Historie

Alle Änderungen zusätzlich in
00_Info\Changelog.txt

Format:

[Datum] [Version] – Beschreibung

🧠 Zusammenfassung
Aufgabe	Datei / Library
System prüfen	Lib_Systeminfo.ps1
Dateistruktur abrufen	Lib_ListFiles.ps1
DebugMode verwalten	Lib_Systeminfo.ps1
Debug-Logs (optional)	Lib_Debug.ps1
Einstellungen-Menü	Menu-Einstellungen.ps1
Systemprüfung	Check-System.ps1
Pfade und Benutzer nutzen	$sysInfo.Systempfade.*
Projektstruktur speichern	Projektstruktur.json
Lokale Daten (JSON, Logs, Backups)	nicht committen
Dokumentation & Änderungen	DEVELOPER_NOTES.md, Changelog.txt

Stand: 18.10.2025
Autor: Herbert Schrotter
Framework-Version: SYS_V1.1.4