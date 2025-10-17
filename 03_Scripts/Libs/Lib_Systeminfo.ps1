# ============================================================
# Library: Lib_Systeminfo.ps1
# Version: LIB_V1.1.0
# Zweck:   Prüft Systeminfo.json bei jedem Modulaufruf
#          Erkennt aktuelles System (User + Computer)
#          und lädt oder erzeugt automatisch passende Daten
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

function Get-SystemInfo {
    param (
        [string]$RootPath = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    )

    $configFile = Join-Path $RootPath "01_Config\Systeminfo.json"
    $detectSystemPath = Join-Path $RootPath "03_Scripts\Modules\Detect-System.ps1"

    $userName = $env:USERNAME
    $computerName = $env:COMPUTERNAME

    # ------------------------------------------------------------
    # 🧾 Datei laden oder erzeugen
    # ------------------------------------------------------------
    if (-not (Test-Path $configFile)) {
        Write-Host "⚠️  Systeminfo.json nicht gefunden – starte Detect-System." -ForegroundColor Yellow
        & $detectSystemPath | Out-Null
    }

    try {
        $sysData = Get-Content $configFile -Raw | ConvertFrom-Json
    } catch {
        Write-Host "⚠️  Fehler beim Lesen der Systeminfo.json – starte Detect-System neu." -ForegroundColor Yellow
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
        Write-Host "➕ Neues System erkannt – füge in Systeminfo.json hinzu." -ForegroundColor Green
        & $detectSystemPath | Out-Null
        $sysData = Get-Content $configFile -Raw | ConvertFrom-Json
        $current = $sysData.Systeme | Where-Object {
            $_.Benutzername -eq $userName -and $_.Computername -eq $computerName
        }
    }

    return $current
}
