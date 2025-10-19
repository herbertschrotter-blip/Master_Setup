# 🚀 PowerShell Master Setup – Geplante Funktionen (mit Prioritäten)

---

## 🧩 System & Framework

* 🟥 **Erweiterte Menü-Navigation mit Unterebenen** (Projekteinstellungen, Logs, Tools) – *P1 Kritisch*
* 🟧 **Anzeige des Firmenmodus bei Systemstart** – *P2 Wichtig*
* 🟩 **Kontextabhängige Debug-Infos** (Modulname, Laufzeit, Pfade) – *P3 Optional*
* 🟧 **Automatisches Backup vor jeder JSON-Änderung** – *P2 Wichtig*
* 🟥 **Automatische Erkennung restriktiver Firmenumgebungen (Read-Only-Modus)** – *P1 Kritisch*
* 🟧 **Fallback auf portable PowerShell-Version bei fehlenden Rechten** – *P2 Wichtig*
* 🟩 **Benutzerfreundliche Fehlermeldungen bei Pfadproblemen** – *P3 Optional*
* 🟩 **Integration von Start-Logs zur Systemstartdiagnose** – *P3 Optional*

---

## 📁 Module

### 🔹 Add-Baustelle.ps1

* 🟥 **Projektsuche & Filter nach Name, Datum oder Status** – *P1 Kritisch*
* 🟧 **Projekt löschen / archivieren / wiederherstellen** – *P2 Wichtig*
* 🟧 **Synchronisation mit OneDrive & automatische Sicherung** – *P2 Wichtig*
* 🟧 **Migration alter JSON-Strukturen** – *P2 Wichtig*
* 🟩 **Statushistorie pro Projekt (Änderungsprotokoll)** – *P3 Optional*
* 🟩 **Integration mit Add-BaustelleOrdner.ps1 zur automatischen Ordnererstellung** – *P3 Optional*
* 🟩 **Anzeige der zuletzt bearbeiteten Projekte** – *P3 Optional*

### 🔹 Backup-Monitor.ps1

* 🟥 **Automatische Sicherung aller wichtigen JSON-Dateien** – *P1 Kritisch*
* 🟧 **Integritätsprüfung der Backups** – *P2 Wichtig*
* 🟧 **Wiederherstellungsfunktion (Restore)** – *P2 Wichtig*

### 🔹 Check-System.ps1

* 🟧 **Erweiterte Anzeige mit Pfad-Status und Schreibrechten** – *P2 Wichtig*
* 🟩 **Vergleich zwischen erwarteter und tatsächlicher Struktur** – *P3 Optional*

### 🔹 Menu-Einstellungen.ps1

* 🟧 **Dynamische Anpassung an Benutzerrechte (Firmenmodus)** – *P2 Wichtig*
* 🟩 **Live-Anzeige von Systemstatus und DebugMode** – *P3 Optional*

### 🔹 Lib_Json.ps1

* 🟥 **Automatische Sicherung vor jedem Schreibvorgang** – *P1 Kritisch*
* 🟧 **Prüfung auf beschädigte oder unvollständige JSON-Dateien** – *P2 Wichtig*
* 🟩 **Option für Validierung des JSON-Schemas** – *P3 Optional*

### 🔹 Lib_Debug.ps1

* 🟧 **Erweiterung um Performance-Monitoring und Laufzeitmessung** – *P2 Wichtig*
* 🟩 **Sitzungs-ID für Tracking** – *P3 Optional*

### 🔹 Lib_Menu.ps1

* 🟧 **Erweiterung der Menülogik mit Rückkehr-Stack (Navigation-Historie)** – *P2 Wichtig*
* 🟩 **Unterstützung von Tastaturkürzeln (z. B. ESC, Enter)** – *P3 Optional*

---

## ⚙️ Infrastruktur

* 🟥 **Automatische Erstellung von verstecktem `.config`-Verzeichnis pro Projekt** – *P1 Kritisch*
* 🟧 **Speicherung von Projektstatus, Benutzeraktionen und Änderungsverlauf** – *P2 Wichtig*
* 🟩 **Einbindung von Systemparametern aus `01_Config\\Systeminfo.json`** – *P3 Optional*

---

## 📘 Dokumentation & Tools

* 🟧 **Erweiterung der Developer Notes mit Beispielen für alle Bibliotheken** – *P2 Wichtig*
* 🟩 **Automatische Changelog-Aktualisierung beim Commit** – *P3 Optional*
* 🟩 **Generierung von Markdown-Übersichten (Module ↔ Libraries)** – *P3 Optional*
* 🟩 **Integration von VS Code Tasks für Modultests** – *P3 Optional*
