# ============================================================
# Modul: Check-System.ps1
# Version: MOD_V1.0.3
# Zweck:   Prüft Systempfade, Umgebung und Ausführungsrichtlinien
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

param()

. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
. "$PSScriptRoot\..\Libs\Lib_Debug.ps1"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     🔍 SYSTEM- UND RICHTLINIEN-PRÜFUNG       " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
    Write-Debug "Systemprüfung gestartet." -Prefix "Check-System"
}

# ------------------------------------------------------------
# ⚙️ Prüfung 1: Ordnerstruktur
# ------------------------------------------------------------
$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (Test-Path "$rootPath\01_Config") {
    Write-Host "✅ Konfigurationsordner gefunden unter:`n   $rootPath\01_Config" -ForegroundColor Green
    Write-Debug "Ordner 01_Config vorhanden." -Prefix "Check-System"
} else {
    Write-Host "⚠️  Ordner '01_Config' fehlt!" -ForegroundColor Red
    Write-Debug "Ordner 01_Config fehlt!" -Prefix "Check-System"
}

# ------------------------------------------------------------
# ⚙️ Prüfung 2: Execution Policy
# ------------------------------------------------------------
$policy = Get-ExecutionPolicy -Scope LocalMachine

Write-Host ""
Write-Host "🧩 Aktuelle PowerShell Execution Policy: $policy" -ForegroundColor Cyan

switch ($policy) {
    "Restricted" {
        Write-Host "❌ Keine Skripte dürfen laufen." -ForegroundColor Red
        Write-Host "➡️  Empfohlen: 'RemoteSigned' oder 'Bypass'" -ForegroundColor Yellow
    }
    "AllSigned" {
        Write-Host "⚠️  Nur signierte Skripte dürfen laufen. Unsigned-Skripte blockiert." -ForegroundColor Yellow
    }
    "RemoteSigned" {
        Write-Host "✅ Lokale Skripte erlaubt, Internet-Skripte müssen signiert sein." -ForegroundColor Green
    }
    "Unrestricted" {
        Write-Host "✅ Alle Skripte dürfen laufen (Warnungen bei Internet-Skripten möglich)." -ForegroundColor Green
    }
    "Bypass" {
        Write-Host "✅ Keine Prüfungen – alle Skripte erlaubt (empfohlen für internes Framework)." -ForegroundColor Green
    }
    Default {
        Write-Host "⚠️  Unbekannte Execution Policy: $policy" -ForegroundColor Yellow
    }
}

Write-Debug "Execution Policy geprüft: $policy" -Prefix "Check-System"

# ------------------------------------------------------------
# ✅ Abschlussmeldung
# ------------------------------------------------------------
Write-Host "`nSystemprüfung abgeschlossen.`n" -ForegroundColor Cyan
Write-Debug "Systemprüfung abgeschlossen." -Prefix "Check-System"
Start-Sleep -Seconds 2
