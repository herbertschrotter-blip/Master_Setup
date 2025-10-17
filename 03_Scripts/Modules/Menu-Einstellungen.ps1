# ============================================================
# Modul: Menu-Einstellungen.ps1
# Version: MENU_V1.0.2
# Zweck:   Untermenü für Einstellungen (DebugMode, Systemprüfung)
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systembibliothek laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"

# ------------------------------------------------------------
# ⚙️ Untermenü: Einstellungen
# ------------------------------------------------------------
do {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "        ⚙️  EINSTELLUNGEN                    " -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan

    # 🔹 Ergänzt: Anzeige des aktuellen DebugMode-Zustands
    $currentState = if (Get-DebugMode) { "🪲 DebugMode: AKTIV" } else { "🟢 DebugMode: AUS" }
    Write-Host "   $currentState" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "1 - Debug Mode umschalten"
    Write-Host "2 - Systemprüfung starten"
    Write-Host "3 - Zurück zum Hauptmenü"
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan

    $sub = Read-Host "Bitte eine Zahl eingeben (1–3)"

    switch ($sub) {
        # ------------------------------------------------------------
        # 🪲 Debug Mode umschalten
        # ------------------------------------------------------------
        "1" {
            $current = Get-DebugMode
            $newValue = -not $current
            Set-DebugMode -Value $newValue
            $state = if ($newValue) { "aktiviert" } else { "deaktiviert" }
            Write-Host "🪲 DebugMode wurde $state." -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
        }

        # ------------------------------------------------------------
        # 🧠 Systemprüfung starten
        # ------------------------------------------------------------
        "2" {
            $checkPath = "$PSScriptRoot\Check-System.ps1"
            if (Test-Path $checkPath) {
                Write-Host "`n➡️  Starte Systemprüfung..." -ForegroundColor Green
                & $checkPath
            } else {
                Write-Host "⚠️  Modul 'Check-System.ps1' nicht gefunden." -ForegroundColor Red
            }
            Start-Sleep -Seconds 1
        }

        # ------------------------------------------------------------
        # 🔙 Zurück zum Hauptmenü
        # ------------------------------------------------------------
        "3" { break }

        default {
            Write-Host "⚠️  Ungültige Eingabe – bitte erneut versuchen." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($sub -ne "3")

# ------------------------------------------------------------
# 🔙 Ergänzt: Nach Rückkehr Master_Controller neu starten
# ------------------------------------------------------------
$masterPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Master_Controller.ps1")
if (Test-Path $masterPath) {
    & $masterPath
    exit
}
else {
    Write-Host "⚠️  Master_Controller.ps1 nicht gefunden – bitte manuell starten." -ForegroundColor Red
}

# 💾 Commit-Vorschlag:
# MENU_V1.0.2 – DebugMode-Statusanzeige ergänzt & automatische Rückkehr zum Hauptmenü integriert
