# ============================================================
# 🧭 MASTER SETUP – SYSTEMSTART
# Version: SYS_V1.1.2
# ============================================================
# Zweck:   Hauptmenü des PowerShell Master Setup Systems
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systeminfo Light-Check
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\03_Scripts\Libs\Lib_Systeminfo.ps1"
    $sysInfo = Get-SystemInfo -Silent

    # 🔧 DebugMode beim Start deaktivieren, falls aktiv
    if ($sysInfo.DebugMode) {
        Write-Host "🧹 DebugMode war aktiv – wird automatisch deaktiviert." -ForegroundColor DarkGray
        Set-DebugMode -Value $false
    }

    Write-Host "🧭 System erkannt: $($sysInfo.Benutzername)@$($sysInfo.Computername)" -ForegroundColor Cyan
}
catch {
    Write-Host "⚠️  Keine gültige Systeminfo. Starte Registrierung..."
    & "$PSScriptRoot\03_Scripts\Modules\Detect-System.ps1"
}

# ------------------------------------------------------------
# 🧭 Hauptmenü anzeigen
# ------------------------------------------------------------
Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "        🧭 MASTER SETUP - HAUPTMENÜ          " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - Neue Baustelle anlegen"
Write-Host "2 - Vorlagen aktualisieren"
Write-Host "3 - Backup prüfen"
Write-Host "4 - Logdateien anzeigen"
Write-Host "5 - Einstellungen"                     # geändert
Write-Host "6 - Beenden"
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 📥 Benutzerabfrage & Modulstart
# ------------------------------------------------------------
$wahl = Read-Host "Bitte eine Zahl eingeben (1–6)"  # bleibt gleich

function Start-Module($name) {
    $path = "$PSScriptRoot\03_Scripts\Modules\$name.ps1"
    if (Test-Path $path) {
        Write-Host "`n➡️  Modul '$name' wird geladen..." -ForegroundColor Green
        & $path
    } else {
        Write-Host "⚠️  Modul '$name.ps1' nicht gefunden." -ForegroundColor Red
    }
}

switch ($wahl) {
    "1" { Start-Module "Add-Baustelle" }
    "2" { Start-Module "Update-Vorlagen" }
    "3" { Start-Module "Backup-Monitor" }
    "4" { Start-Module "Show-Logs" }
    "5" { & "$PSScriptRoot\03_Scripts\Modules\Menu-Einstellungen.ps1" }   # geändert
    "6" {
        Write-Host "`n👋  Programm wird beendet..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        exit
    }
    default {
        Write-Host "`n⚠️  Ungültige Eingabe! Bitte erneut versuchen." -ForegroundColor Red
        Start-Sleep -Seconds 1
        & "$PSCommandPath"
    }
}

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "📘 Master Controller wurde korrekt ausgeführt." -ForegroundColor Green
Write-Host "=============================================`n" -ForegroundColor Cyan

