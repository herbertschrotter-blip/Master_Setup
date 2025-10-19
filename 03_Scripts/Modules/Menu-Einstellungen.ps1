# ============================================================
# Modul: Menu-Einstellungen.ps1
# Version: MENU_V1.0.4
# Zweck:   Untermenü für Einstellungen (DebugMode, Systemprüfung, Projektstruktur)
# Autor:   Herbert Schrotter
# Datum:   19.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systembibliothek & Menü-Library laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
    . "$PSScriptRoot\..\Libs\Lib_Menu.ps1"
}
catch {
    Write-Host "❌ Bibliotheken konnten nicht geladen werden: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# ------------------------------------------------------------
# ⚙️ Menüdefinition über zentrale Library
# ------------------------------------------------------------
Show-SubMenu -MenuTitle "⚙️  EINSTELLUNGEN" -Options @{
    "1" = "Debug Mode umschalten|& '$PSScriptRoot\Toggle-Debug.ps1'"
    "2" = "Systemprüfung starten|& '$PSScriptRoot\Check-System.ps1'"
    "3" = "Projektstruktur auflisten|& '$PSScriptRoot\List-Files.ps1'"
}

# ------------------------------------------------------------
# 🔙 Nach Rückkehr Master_Controller neu starten
# ------------------------------------------------------------
try {
    $masterPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Master_Controller.ps1")
    if (Test-Path $masterPath) {
        & $masterPath
        exit
    }
    else {
        Write-Host "⚠️ Master_Controller.ps1 nicht gefunden – bitte manuell starten." -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Fehler beim Neustart des Master_Controller: $($_.Exception.Message)" -ForegroundColor Red
}
