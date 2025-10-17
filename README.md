# 🧭 PowerShell Master Setup Tool

### Version: SYS_V1.0.0  
**Autor:** Herbert Schrotter  
**Erstellt am:** 17.10.2025  

---

## 📘 Zweck
Das **Master Setup Tool** dient als zentrale Steuerung für Automatisierungs- und Verwaltungsprozesse.  
Es wurde in **PowerShell** entwickelt und modular aufgebaut, um verschiedene Aufgaben wie:
- Baustellenverwaltung  
- Vorlagenaktualisierung  
- Backup-Management  
- Log-Analyse  
- Systemprüfungen  

zu automatisieren und in einer einzigen Oberfläche zu vereinen.

---

## 📁 Verzeichnisstruktur
```plaintext
00_MASTER_SETUP/
├── 00_Info/
├── 01_Config/
├── 02_Templates/
├── 03_Scripts/
│   ├── Libs/
│   └── Modules/
├── 04_Logs/
└── 05_Backup/

⚙️ Aktueller Entwicklungsstand

✅ Hauptmenü erstellt (Master_Controller.ps1)

🔜 Module werden schrittweise integriert
(z. B. Check-System.ps1, Add-Baustelle.ps1, etc.)

💾 Nutzung

Starte das Tool über:

.\Master_Controller.ps1

🧩 Lizenz

Dieses Projekt ist für den privaten Gebrauch von Herbert Schrotter bestimmt.
Eine Weitergabe oder Veröffentlichung ist ohne Zustimmung nicht erlaubt.