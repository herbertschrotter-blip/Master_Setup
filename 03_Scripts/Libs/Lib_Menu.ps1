# ============================================================
# Library: Lib_Menu.ps1
# Version: LIB_V1.0.2
# Zweck:   Einheitliche Menüführung mit Rückkehrfunktion
# Autor:   Herbert Schrotter
# Datum:   19.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systeminfo & DebugMode initial laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\Lib_Systeminfo.ps1"
    $debugMode = Get-DebugMode
}
catch {
    Write-Host "⚠️ Lib_Systeminfo konnte nicht geladen werden: $($_.Exception.Message)" -ForegroundColor Yellow
    $debugMode = $false
}

# ------------------------------------------------------------
# 📋 Funktion: Show-SubMenu
# ------------------------------------------------------------
function Show-SubMenu {
    <#
        .SYNOPSIS
            Zeigt ein Untermenü mit beliebigen Optionen an.

        .DESCRIPTION
            Einheitliche Menülogik für alle Module im PowerShell Master Setup.
            Unterstützt DebugMode und Rückkehrfunktion mit Taste „0“ oder „z“.

        .PARAMETER MenuTitle
            Überschrift des Menüs.

        .PARAMETER Options
            Hashtable mit Menüeinträgen und Befehlen.
            Beispiel:
                @{
                    "1" = "Neue Baustelle anlegen|Add-NewProject"
                    "2" = "Projektliste anzeigen|Show-ProjectList"
                }

        .NOTES
            Nutzt $debugMode aus Lib_Systeminfo.ps1
    #>

    param(
        [Parameter(Mandatory)][string]$MenuTitle,
        [Parameter(Mandatory)][hashtable]$Options
    )

    while ($true) {
        Clear-Host

        # 🧠 DebugMode neu prüfen (live in jeder Schleife)
        try {
            $debugMode = Get-DebugMode
        }
        catch {
            $debugMode = $false
        }

        # --------------------------------------------------------
        # 🧾 Menüanzeige mit optionalem Debug-Hinweis
        # --------------------------------------------------------
        Write-Host "============================================="
        Write-Host "        $MenuTitle"
        Write-Host "============================================="

        if ($debugMode) {
            Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
            Write-Host ""
        }

        foreach ($key in $Options.Keys) {
            Write-Host "$key - $($Options[$key].Split('|')[0])"
        }

        Write-Host "`n0 - Zurück zum vorherigen Menü"

        # --------------------------------------------------------
        # 🧮 Benutzereingabe
        # --------------------------------------------------------
        $choice = Read-Host "`nBitte Auswahl eingeben"

        if ($choice -eq "0" -or $choice -eq "z") { break }

        if ($Options.ContainsKey($choice)) {
            $action = $Options[$choice].Split('|')[1]

            if ($debugMode) {
                Write-Host "→ Ausführung: $action" -ForegroundColor DarkGray
            }

            try {
                Invoke-Expression $action
            }
            catch {
                Write-Host "❌ Fehler beim Ausführen von '$action': $($_.Exception.Message)" -ForegroundColor Red
            }

            Pause
        }
        else {
            Write-Host "⚠️ Ungültige Eingabe. Bitte erneut versuchen." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
