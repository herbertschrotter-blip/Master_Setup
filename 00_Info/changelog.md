# 🧾 PowerShell Master Setup – Changelog

---

## 📅 2025-10-19 – System-Stabilisierung & Strukturfinalisierung

**Version:** SYS_V1.1.6

**Änderungen:**

* DebugMode-System global integriert (nur Beenden deaktiviert)
* Einheitliche Menüführung in allen Modulen
* Rückkehrfunktion zu Hauptmenü in Menu-Einstellungen.ps1
* ASCII-Ausgabe in Add-Baustelle überarbeitet (Spaltenbreite fixiert)

---

## 📅 2025-10-18 – Framework-Reorganisation

**Version:** SYS_V1.1.4

**Änderungen:**

* Einführung globaler DebugMode-Verwaltung (Lib_Systeminfo)
* Lib_Debug.ps1 hinzugefügt (Write-DebugLog, Write-DebugFile)
* Check-System.ps1 an neue Struktur angepasst
* Menüpunkt „Einstellungen“ im Hauptmenü ergänzt

---

## 📅 2025-10-17 – JSON-System & Bibliotheken

**Version:** MOD_V1.1.1 / LIB_V1.2.4

**Add-Baustelle.ps1:**

* Neues JSON-Modell: zentrale Projektliste mit Info-Objekten
* Systemunabhängige Speicherung (Benutzer/Computer/Pfad)
* DebugMode-Anzeige integriert

**Lib_Json.ps1:**

* Funktionen Get/Save/Add-JsonFile
* Fehlerbehandlung bei beschädigten Dateien
* Erste Integration in Add-Baustelle.ps1

---

## 📅 2025-10-16 – Basissystem & Setup

**Version:** SYS_V1.0.0

**Änderungen:**

* Master_Controller.ps1 erstellt (Hauptmenü)
* Systemerkennung via Detect-System.ps1
* Erstellung von Systeminfo.json automatisiert
* Strukturprüfung über Check-System.ps1
* Lib_ListFiles.ps1 implementiert (Projektstruktur)

---

## 📅 2025-10-15 – Initial Commit

**Version:** SYS_V0.9.0

**Projektstart PowerShell Master Setup**

* Ordnerstruktur 00–05 eingerichtet
* Git-Struktur und .gitignore erstellt
* README.md und Start_MasterSetup.cmd hinzugefügt

