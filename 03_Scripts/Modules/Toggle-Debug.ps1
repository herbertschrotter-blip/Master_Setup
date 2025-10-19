# ============================================================
# Modul: Toggle-Debug.ps1
# Version: MOD_V1.0.0
# Zweck:   Schaltet den globalen DebugMode (an/aus)
# Autor:   Herbert Schrotter
# Datum:   19.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systembibliothek laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
}
catch {
    Write-Host "❌ Fehler: Lib_Systeminfo konnte nicht geladen werden." -ForegroundColor Red
    exit
}

# ------------------------------------------------------------
# 🪲 DebugMode umschalten
# ------------------------------------------------------------
try {
    $current = Get-DebugMode
    $newValue = -not $current
    Set-DebugMode -Value $newValue

    $state = if ($newValue) { "🪲 DebugMode wurde aktiviert." } else { "🟢 DebugMode wurde deaktiviert." }
    Write-Host "`n$state" -ForegroundColor DarkGray
}
catch {
    Write-Host "❌ Fehler beim Umschalten des DebugMode: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------
# 🔙 Rückkehr
# ------------------------------------------------------------
Pause
return
