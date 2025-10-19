# ============================================================
# Library: Lib_Menu.ps1
# Version: LIB_V1.0.3
# Zweck:   Einheitliche Menüführung mit Rückkehrfunktion
# Autor:   Herbert Schrotter
# Datum:   19.10.2025
# ============================================================

function Show-SubMenu {
    <#
        .SYNOPSIS
            Zeigt ein Untermenü mit beliebigen Optionen an.

        .PARAMETER MenuTitle
            Überschrift des Menüs (Zeilenumbruch mit `n möglich).

        .PARAMETER Options
            Hashtable: "Taste" = "Beschriftung|Aktion"

        .PARAMETER ReturnAfterAction
            Wenn gesetzt: Nach Ausführen EINER Aktion zurückkehren,
            damit der Aufrufer Daten neu berechnen und das Menü neu
            zeichnen kann (z. B. Statuszeile aktualisieren).

        .OUTPUTS
            Gibt die getroffene Auswahl zurück (z. B. "1") oder "0"/"z" bei Zurück.
    #>

    param(
        [Parameter(Mandatory)][string]$MenuTitle,
        [Parameter(Mandatory)][hashtable]$Options,
        [switch]$ReturnAfterAction
    )

    # Systeminfo laden (wie gehabt)
    try {
        . "$PSScriptRoot\Lib_Systeminfo.ps1"
        $debugMode = Get-DebugMode
    } catch { $debugMode = $false }

    while ($true) {
        Clear-Host
        try { $debugMode = Get-DebugMode } catch { $debugMode = $false }

        Write-Host "============================================="
        Write-Host ("        " + ($MenuTitle -replace '^\s+', ''))
        Write-Host "============================================="
        if ($debugMode) { Write-Host "🪲 DEBUG-MODE AKTIVIERT`n" -ForegroundColor DarkYellow }

        foreach ($key in $Options.Keys) {
            Write-Host "$key - $($Options[$key].Split('|')[0])"
        }
        Write-Host "`n0 - Zurück zum vorherigen Menü"

        $choice = Read-Host "`nBitte Auswahl eingeben"
        if ($choice -eq "0" -or $choice -eq "z") { return "0" }

        if ($Options.ContainsKey($choice)) {
            $action = $Options[$choice].Split('|')[1]
            if ($debugMode) { Write-Host "→ Ausführung: $action" -ForegroundColor DarkGray }
            try { Invoke-Expression $action }
            catch {
                Write-Host "❌ Fehler beim Ausführen von '$action': $($_.Exception.Message)" -ForegroundColor Red
            }
            Pause
            if ($ReturnAfterAction) { return $choice }  # ⬅️ WICHTIG: nach Aktion zurückkehren
        }
        else {
            Write-Host "⚠️ Ungültige Eingabe. Bitte erneut versuchen." -ForegroundColor Red
            Start-Sleep 1
        }
    }
}
