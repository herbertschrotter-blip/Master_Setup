# ============================================================
# Library: Lib_ListFiles.ps1
# Version: LIB_V1.0.0
# Zweck:   Stellt Funktionen bereit, um Ordner- und Dateistrukturen
#          dynamisch basierend auf dem aktiven System zu ermitteln.
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

# ------------------------------------------------------------
# Funktion: Get-ProjectStructure
# Zweck:    Liest alle Dateien und Ordner aus dem Master-Setup
# Rückgabe: Objekt mit Listen von Dateien & Ordnern
# ------------------------------------------------------------
function Get-ProjectStructure {
    param (
        [switch]$AsJson
    )

    # Systeminfo laden
    . "$PSScriptRoot\Lib_Systeminfo.ps1"
    $sysInfo = Get-SystemInfo
    $rootPath = $sysInfo.Systempfade.RootPath

    Write-Host "🧭 Aktives System: $($sysInfo.Computername) | Benutzer: $($sysInfo.Benutzername)" -ForegroundColor Cyan
    Write-Host "📂 Verwende RootPath: $rootPath" -ForegroundColor Green

    # Daten erfassen
    $folders = Get-ChildItem -Path $rootPath -Directory -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName
    $files   = Get-ChildItem -Path $rootPath -File -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName

    $data = [PSCustomObject]@{
        System      = $sysInfo.Computername
        Benutzer    = $sysInfo.Benutzername
        ProjektRoot = $rootPath
        ErstelltAm  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Ordner      = $folders.FullName
        Dateien     = $files.FullName
    }

    # Wenn JSON gewünscht
    if ($AsJson) {
        $jsonPath = Join-Path -Path $sysInfo.Systempfade.ConfigPath -ChildPath "Projektstruktur.json"
        $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8
        Write-Host "`n✅ Struktur gespeichert unter:`n   $jsonPath" -ForegroundColor Green
    }

    return $data
}
