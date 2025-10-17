# ============================================================
# 🧭 MASTER SETUP – SYSTEMSTART
# Version: SYS_V1.0.0
# ============================================================
# Zweck:   Hauptmenü des neuen Master Setup Systems
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "        🧭 MASTER SETUP - HAUPTMENÜ          " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - Neue Baustelle anlegen"
Write-Host "2 - Vorlagen aktualisieren"
Write-Host "3 - Backup prüfen"
Write-Host "4 - Logdateien anzeigen"
Write-Host "5 - Systemprüfung"
Write-Host "6 - Beenden"
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan

# Benutzerabfrage
$wahl = Read-Host "Bitte eine Zahl eingeben (1–6)"

switch ($wahl) {
    "1" { Write-Host "`n➡️  Modul 'Add-Baustelle' wird geladen..." -ForegroundColor Green }
    "2" { Write-Host "`n➡️  Modul 'Update-Vorlagen' wird geladen..." -ForegroundColor Green }
    "3" { Write-Host "`n➡️  Modul 'Backup-Monitor' wird geladen..." -ForegroundColor Green }
    "4" { Write-Host "`n➡️  Modul 'Logs anzeigen' wird geladen..." -ForegroundColor Green }
    "5" { Write-Host "`n➡️  Modul 'Check-System' wird geladen..." -ForegroundColor Green }
    "6" { 
        Write-Host "`n👋  Programm wird beendet..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        exit
    }
    default {
        Write-Host "`n⚠️  Ungültige Eingabe! Bitte erneut versuchen." -ForegroundColor Red
        Start-Sleep -Seconds 1
        & "$PSCommandPath"   # Neustart des Skripts
    }
}

