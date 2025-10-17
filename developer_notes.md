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
│   ├── Libs/ ← zentrale Bibliotheken
│   │   ├── Lib_Systeminfo.ps1
│   │   ├── Lib_ListFiles.ps1
│   │   └── Lib_Debug.ps1 (optional)
│   └── Modules/ ← eigenständige Module
│       ├── Detect-System.ps1
│       ├── List-Files.ps1
│       ├── Menu-Einstellungen.ps1
│       └── ...
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

powershell
Code kopieren
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

$sysInfo.DebugMode

3️⃣ Dateistruktur laden (falls benötigt)
powershell
Code kopieren
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

powershell
Code kopieren
try {
    # Code
}
catch {
    Write-Host "❌ Fehler: $($_.Exception.Message)" -ForegroundColor Red
}
5️⃣ DebugMode (neu seit SYS_V1.1.4)
Der DebugMode ist eine globale Einstellung, die in der Datei
01_Config\Systeminfo.json gespeichert wird.

Zweck: Aktiviert erweiterte Konsolenausgaben und Debug-Logs in allen Modulen.

Verwaltung:
Erfolgt über die Funktionen in Lib_Systeminfo.ps1:

Get-DebugMode → gibt aktuellen Zustand zurück ($true / $false)

Set-DebugMode -Value $true|$false → schaltet DebugMode global ein/aus

Eigenschaften:

bleibt aktiv, bis das Framework beendet wird

wird nur beim Menüpunkt "Beenden" automatisch auf false gesetzt

zeigt in jedem Menübereich den Hinweis
🪲 DEBUG-MODE AKTIVIERT, wenn aktiv

Beispiel:

powershell
Code kopieren
if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
}
Beispielhafte Systeminfo.json mit DebugMode:

json
Code kopieren
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
6️⃣ Untermenüs (neu)
Seit Version SYS_V1.3.0 können Menüs modular ausgelagert werden.

Beispiel:

css
Code kopieren
03_Scripts\Modules\Menu-Einstellungen.ps1
Dieses Untermenü verwaltet:

DebugMode (an/aus)

Systemprüfung

Rückkehr zum Hauptmenü (Master_Controller.ps1)

Aufruf im Controller:

powershell
Code kopieren
"5" { & "$PSScriptRoot\03_Scripts\Modules\Menu-Einstellungen.ps1" }
Beim Verlassen kehrt das Untermenü automatisch zum Hauptmenü zurück:

powershell
Code kopieren
$masterPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Master_Controller.ps1")
& $masterPath
exit
7️⃣ Versions- und Commit-Regeln
JSON-, Log- und Backup-Dateien nie committen (.gitignore)

Nur Skripte, Libraries, README, Changelogs und Developer Notes versionieren

Commit immer mit Modul- oder Library-Kennung + Beschreibung

Beispiele:

pgsql
Code kopieren
SYS_V1.1.4 – DebugMode-Anzeige im Hauptmenü integriert; Deaktivierung nur bei Beenden
MENU_V1.0.2 – DebugMode-Statusanzeige ergänzt & automatische Rückkehr zum Hauptmenü integriert
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
auf Basis der in Lib_Systeminfo erkannten Pfade.

Hauptfunktion:
Get-ProjectStructure [-AsJson]

🔹 Lib_Debug.ps1 (optional, ab SYS_V1.4)
Optionale Hilfsbibliothek für zentrale Debug-Ausgaben.

Geplante Funktionen:

Write-DebugLog "Text" → gibt Meldung nur bei aktivem DebugMode aus

Write-DebugFile "Text" → schreibt Meldungen zusätzlich in 04_Logs\Debug.log

🧱 Versionsverwaltung & Commit-Regeln
Immer folgende Schritte befolgen:

Code testen (PowerShell-Konsole oder VS Code)

Nur funktionierende Versionen committen

Kurze, prägnante Commit-Nachricht:

sql
Code kopieren
SYS_V1.1.0 – Systemerkennung beim Start integriert
Nach erfolgreichem Commit:

perl
Code kopieren
git push
📓 Changelog / Historie
Alle Änderungen zusätzlich in
00_Info\Changelog.txt

Format:

css
Code kopieren
[Datum] [Version] – Beschreibung
🧠 Zusammenfassung
Aufgabe	Datei / Library
System prüfen	Lib_Systeminfo.ps1
Dateistruktur abrufen	Lib_ListFiles.ps1
DebugMode verwalten	Lib_Systeminfo.ps1
Debug-Logs (optional)	Lib_Debug.ps1
Einstellungen-Menü	Menu-Einstellungen.ps1
Pfade und Benutzer nutzen	$sysInfo.Systempfade.*
Projektstruktur speichern	Projektstruktur.json
Lokale Daten (JSON, Logs, Backups)	nicht committen
Dokumentation & Änderungen	DEVELOPER_NOTES.md, Changelog.txt

Stand: 17.10.2025
Autor: Herbert Schrotter
Framework-Version: SYS_V1.1.4