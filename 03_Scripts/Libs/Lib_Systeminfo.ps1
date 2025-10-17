# ============================================================
# Library: Lib_Systeminfo.ps1
# Version: LIB_V1.2.1
# Zweck:   Prüft Systeminfo.json bei jedem Modulaufruf
#          Erkennt aktuelles System (User + Computer)
#          Lädt globale Einstellungen wie DebugMode
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

function Get-SystemInfo {
    param (
        [string]$RootPath = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
        [switch]$Silent
    )

    $configFile = Join-Path $RootPath "01_Config\Systeminfo.json"
    $detectSystemPath = Join-Path $RootPath "03_Scripts\Modules\Detect-System.ps1"

    $userName = $env:USERNAME
    $computerName = $env:COMPUTERNAME

    # ------------------------------------------------------------
    # 🧾 Datei laden oder erzeugen
    # ------------------------------------------------------------
    if (-not (Test-Path $configFile)) {
        if (-not $Silent) { Write-Host "⚠️  Systeminfo.json nicht gefunden – starte Detect-System." -ForegroundColor Yellow }
        & $detectSystemPath | Out-Null
    }

    try {
        $sysData = Get-Content $configFile -Raw | ConvertFrom-Json
    } catch {
        if (-not $Silent) { Write-Host "⚠️  Fehler beim Lesen der Systeminfo.json – starte Detect-System neu." -ForegroundColor Yellow }
        & $detectSystemPath | Out-Null
        $sysData = Get-Content $configFile -Raw | ConvertFrom-Json
    }

    # ------------------------------------------------------------
    # 🔍 Aktuelles System suchen
    # ------------------------------------------------------------
    $current = $sysData.Systeme | Where-Object {
        $_.Benutzername -eq $userName -and $_.Computername -eq $computerName
    }

    if (-not $current) {
        if (-not $Silent) { Write-Host "➕ Neues System erkannt – füge in Systeminfo.json hinzu." -ForegroundColor Green }
        & $detectSystemPath | Out-Null
        $sysData = Get-Content $configFile -Raw | ConvertFrom-Json
        $current = $sysData.Systeme | Where-Object {
            $_.Benutzername -eq $userName -and $_.Computername -eq $computerName
        }
    }

    # ------------------------------------------------------------
    # 🧩 DebugMode übernehmen (global oder systembezogen)
    # ------------------------------------------------------------
    $debugMode = $false
    if ($sysData.PSObject.Properties.Name -contains 'DebugMode') {
        $debugMode = [bool]$sysData.DebugMode
    } elseif ($current.PSObject.Properties.Name -contains 'DebugMode') {
        $debugMode = [bool]$current.DebugMode
    }

    if (-not $Silent -and $debugMode) {
        Write-Host "🪲 DebugMode ist AKTIV (global oder systembezogen)" -ForegroundColor DarkGray
    }

    $current | Add-Member -NotePropertyName DebugMode -NotePropertyValue $debugMode -Force

    return $current
}

# ============================================================
# Hilfsfunktionen für DebugMode-Verwaltung
# ============================================================

function Get-DebugMode {
    param(
        [string]$RootPath = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    )

    $configFile = Join-Path $RootPath "01_Config\Systeminfo.json"
    if (-not (Test-Path $configFile)) { return $false }

    try {
        $json = Get-Content $configFile -Raw | ConvertFrom-Json
        return [bool]$json.DebugMode
    } catch {
        return $false
    }
}

function Set-DebugMode {
    param(
        [bool]$Value,
        [string]$RootPath = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    )

    $configFile = Join-Path $RootPath "01_Config\Systeminfo.json"
    if (-not (Test-Path $configFile)) {
        Write-Host "⚠️  Systeminfo.json nicht gefunden, DebugMode kann nicht geändert werden." -ForegroundColor Yellow
        return
    }

    try {
        # Schreibschutz prüfen und ggf. entfernen
        $file = Get-Item $configFile
        if ($file.IsReadOnly) {
            Write-Host "⚙️  Entferne Schreibschutz von Systeminfo.json ..." -ForegroundColor DarkGray
            $file.IsReadOnly = $false
        }

        # JSON laden
        $json = Get-Content $configFile -Raw | ConvertFrom-Json

        # 🔧 Falls DebugMode fehlt, neu anlegen
        if (-not ($json.PSObject.Properties.Name -contains 'DebugMode')) {
            Write-Host "➕ DebugMode-Eintrag neu angelegt." -ForegroundColor DarkGray
            $json | Add-Member -NotePropertyName DebugMode -NotePropertyValue $Value -Force
        }
        else {
            $json.DebugMode = $Value
        }

        # Sicher speichern mit UTF8
        $json | ConvertTo-Json -Depth 5 | Out-File -FilePath $configFile -Encoding utf8 -Force

        $state = if ($Value) { "AKTIV" } else { "DEAKTIVIERT" }
        Write-Host "🪲 DebugMode wurde auf $state gesetzt." -ForegroundColor DarkGray
    }
    catch {
        Write-Host "❌ Fehler beim Setzen des DebugMode in:`n$configFile" -ForegroundColor Red
        Write-Host "💡 Fehlermeldung: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
