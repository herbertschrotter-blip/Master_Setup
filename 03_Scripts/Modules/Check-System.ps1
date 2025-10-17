# ============================================================
# Modul: Check-System.ps1
# Version: MOD_V1.0.0
# Zweck:   Prüft Systempfade und Umgebung des Master Setups
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

param()

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     🔍 SYSTEM- UND RICHTLINIEN-PRÜFUNG       " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# Beispiel: RootPath prüfen
$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (Test-Path "$rootPath\01_Config") {
    Write-Host "✅ Konfigurationsordner gefunden unter:`n   $rootPath\01_Config" -ForegroundColor Green
} else {
    Write-Host "⚠️  Ordner '01_Config' fehlt!" -ForegroundColor Red
}

Write-Host "`nSystemprüfung abgeschlossen.`n" -ForegroundColor Cyan
Start-Sleep -Seconds 2
