# ============================================================
# Modul: List-Files.ps1
# Version: MOD_V1.1.0
# Zweck:   Listet alle Ordner und Dateien im Master Setup auf
#          und speichert die Struktur als JSON im Config-Ordner.
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

param()

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     📂 ORDNER- UND DATEIÜBERSICHT            " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# Basisverzeichnis des Projekts (zwei Ebenen über Modules)
$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Zielpfad für JSON-Datei
$jsonPath = Join-Path -Path $rootPath -ChildPath "01_Config\Projektstruktur.json"

# Prüfen, ob Basisverzeichnis existiert
if (-not (Test-Path $rootPath)) {
    Write-Host "⚠️  Projektpfad wurde nicht gefunden: $rootPath" -ForegroundColor Red
    exit
}

Write-Host "`n📁 Projektverzeichnis: $rootPath`n" -ForegroundColor Green

# ------------------------------------------------------------
# 📂 Ordner und Dateien erfassen
# ------------------------------------------------------------

# Alle Unterordner
$folders = Get-ChildItem -Path $rootPath -Directory -Recurse | Sort-Object FullName

# Alle Dateien
$files = Get-ChildItem -Path $rootPath -File -Recurse | Sort-Object FullName

# JSON-Struktur vorbereiten
$data = [PSCustomObject]@{
    ProjektRoot = $rootPath
    ErstelltAm  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Ordner      = $folders.FullName
    Dateien     = $files.FullName
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
