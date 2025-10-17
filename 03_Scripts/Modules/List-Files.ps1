# ============================================================
# Modul: List-Files.ps1
# Version: MOD_V1.2.0
# Zweck:   Listet alle Ordner und Dateien im Master Setup auf
#          und speichert die Struktur als JSON im Config-Ordner.
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

param()

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     📂 ORDNER- UND DATEIÜBERSICHT            " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 🧠 System- und Pfadinformationen laden
# ------------------------------------------------------------
try {
    # Library einbinden
    . "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"

    # Aktuelles System ermitteln (lädt oder erstellt JSON automatisch)
    $sysInfo = Get-SystemInfo

    # RootPath aus der Systeminfo verwenden
    $rootPath = $sysInfo.Systempfade.RootPath

    Write-Host "`n🧭 Aktives System: $($sysInfo.Computername) | Benutzer: $($sysInfo.Benutzername)" -ForegroundColor Cyan
    Write-Host "📂 RootPath: $rootPath`n" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ Fehler beim Laden der Systeminformationen:`n$($_.Exception.Message)" -ForegroundColor Red
    exit
}

# ------------------------------------------------------------
# 📁 JSON-Zielpfad für Projektstruktur
# ------------------------------------------------------------
$jsonPath = Join-Path -Path $sysInfo.Systempfade.ConfigPath -ChildPath "Projektstruktur.json"

# ------------------------------------------------------------
# 📂 Ordner und Dateien erfassen
# ------------------------------------------------------------
if (-not (Test-Path $rootPath)) {
    Write-Host "⚠️  Projektpfad wurde nicht gefunden: $rootPath" -ForegroundColor Red
    exit
}

# Alle Unterordner
$folders = Get-ChildItem -Path $rootPath -Directory -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName

# Alle Dateien
$files = Get-ChildItem -Path $rootPath -File -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName

# JSON-Struktur vorbereiten
$data = [PSCustomObject]@{
    System       = $sysInfo.Computername
    Benutzer     = $sysInfo.Benutzername
    ProjektRoot  = $rootPath
    ErstelltAm   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Ordner       = $folders.FullName
    Dateien      = $files.FullName
}

# ------------------------------------------------------------
# 💾 JSON-Datei schreiben
# ------------------------------------------------------------
try {
    $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "`n✅ Projektstruktur gespeichert unter:`n   $jsonPath" -ForegroundColor Green
}
catch {
    Write-Host "`n⚠️  Fehler beim Schreiben der JSON-Datei:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}

# ------------------------------------------------------------
# 🧾 Kurze Übersicht im Terminal
# ------------------------------------------------------------
Write-Host "`n🗂️  Gefundene Ordner: $($folders.Count)" -ForegroundColor Cyan
Write-Host "📄 Gefundene Dateien: $($files.Count)" -ForegroundColor Cyan
Write-Host "`n✅ Auflistung abgeschlossen.`n" -ForegroundColor Green
Start-Sleep -Seconds 2
