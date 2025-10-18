# ============================================================
# Modul: List-Files.ps1
# Version: MOD_V1.2.1
# Zweck:   Listet alle Ordner und Dateien im Master Setup auf
#          und speichert die Struktur als JSON im Config-Ordner.
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

param()

# ------------------------------------------------------------
# 🧠 System- & Debug-Bibliotheken laden
# ------------------------------------------------------------
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
. "$PSScriptRoot\..\Libs\Lib_Debug.ps1"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     📂 ORDNER- UND DATEIÜBERSICHT            " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
    Write-Debug "Starte Ordner- und Dateiauflistung..." -Prefix "List-Files"
}

# ------------------------------------------------------------
# 🧠 System- und Pfadinformationen laden
# ------------------------------------------------------------
try {
    Write-Debug "Lade Lib_Systeminfo..." -Prefix "List-Files"

    $sysInfo = Get-SystemInfo
    $rootPath = $sysInfo.Systempfade.RootPath

    Write-Host "`n🧭 Aktives System: $($sysInfo.Computername) | Benutzer: $($sysInfo.Benutzername)" -ForegroundColor Cyan
    Write-Host "📂 RootPath: $rootPath`n" -ForegroundColor Green

    Write-Debug "Systeminfo geladen. RootPath: $rootPath" -Prefix "List-Files"
}
catch {
    Write-Host "`n❌ Fehler beim Laden der Systeminformationen:`n$($_.Exception.Message)" -ForegroundColor Red
    Write-Debug "Fehler beim Laden der Systeminformationen: $($_.Exception.Message)" -Prefix "List-Files"
    exit
}

# ------------------------------------------------------------
# 📁 JSON-Zielpfad für Projektstruktur
# ------------------------------------------------------------
$jsonPath = Join-Path -Path $sysInfo.Systempfade.ConfigPath -ChildPath "Projektstruktur.json"
Write-Debug "JSON-Zielpfad: $jsonPath" -Prefix "List-Files"

# ------------------------------------------------------------
# 📂 Ordner und Dateien erfassen
# ------------------------------------------------------------
if (-not (Test-Path $rootPath)) {
    Write-Host "⚠️  Projektpfad wurde nicht gefunden: $rootPath" -ForegroundColor Red
    Write-Debug "Projektpfad nicht gefunden: $rootPath" -Prefix "List-Files"
    exit
}

Write-Debug "Starte rekursive Auflistung der Ordner und Dateien..." -Prefix "List-Files"

# Alle Unterordner
$folders = Get-ChildItem -Path $rootPath -Directory -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName
Write-Debug "Ordneranzahl: $($folders.Count)" -Prefix "List-Files"

# Alle Dateien
$files = Get-ChildItem -Path $rootPath -File -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName
Write-Debug "Dateianzahl: $($files.Count)" -Prefix "List-Files"

# JSON-Struktur vorbereiten
$data = [PSCustomObject]@{
    System       = $sysInfo.Computername
    Benutzer     = $sysInfo.Benutzername
    ProjektRoot  = $rootPath
    ErstelltAm   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Ordner       = $folders.FullName
    Dateien      = $files.FullName
}
Write-Debug "Datenstruktur für JSON vorbereitet." -Prefix "List-Files"

# ------------------------------------------------------------
# 💾 JSON-Datei schreiben
# ------------------------------------------------------------
try {
    $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "`n✅ Projektstruktur gespeichert unter:`n   $jsonPath" -ForegroundColor Green
    Write-Debug "Projektstruktur gespeichert unter: $jsonPath" -Prefix "List-Files"
}
catch {
    Write-Host "`n⚠️  Fehler beim Schreiben der JSON-Datei:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Write-Debug "Fehler beim Schreiben der JSON-Datei: $($_.Exception.Message)" -Prefix "List-Files"
}

# ------------------------------------------------------------
# 🧾 Kurze Übersicht im Terminal
# ------------------------------------------------------------
Write-Host "`n🗂️  Gefundene Ordner: $($folders.Count)" -ForegroundColor Cyan
Write-Host "📄 Gefundene Dateien: $($files.Count)" -ForegroundColor Cyan
Write-Host "`n✅ Auflistung abgeschlossen.`n" -ForegroundColor Green

Write-Debug "Auflistung abgeschlossen. Ordner: $($folders.Count), Dateien: $($files.Count)" -Prefix "List-Files"

Start-Sleep -Seconds 2
