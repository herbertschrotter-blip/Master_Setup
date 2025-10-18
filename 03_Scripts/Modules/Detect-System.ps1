# ============================================================
# Modul: Detect-System.ps1
# Version: MOD_V1.1.1
# Zweck:   Erkennt Benutzer- und Systeminformationen
#          und speichert bzw. aktualisiert Systeminfo.json (Multi-System-Support)
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
Write-Host "     💻 SYSTEM- UND BENUTZERERKENNUNG         " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
    Write-Debug "Starte Systemerkennung..." -Prefix "Detect-System"
}

# ------------------------------------------------------------
# 🔍 Benutzer- und Systeminfos ermitteln
# ------------------------------------------------------------
$userName     = $env:USERNAME
$computerName = $env:COMPUTERNAME
$userProfile  = $env:USERPROFILE
$osVersion    = (Get-CimInstance Win32_OperatingSystem).Caption
$rootPath     = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Debug "Benutzer: $userName" -Prefix "Detect-System"
Write-Debug "Computer: $computerName" -Prefix "Detect-System"
Write-Debug "Betriebssystem: $osVersion" -Prefix "Detect-System"
Write-Debug "RootPath erkannt: $rootPath" -Prefix "Detect-System"

# ------------------------------------------------------------
# 📁 Systempfade dynamisch aufbauen
# ------------------------------------------------------------
$systemPaths = [ordered]@{
    RootPath        = $rootPath
    ConfigPath      = Join-Path $rootPath "01_Config"
    TemplatePath    = Join-Path $rootPath "02_Templates"
    ScriptPath      = Join-Path $rootPath "03_Scripts"
    LogPath         = Join-Path $rootPath "04_Logs"
    BackupPath      = Join-Path $rootPath "05_Backup"
    ProjectsBase    = "D:\OneDrive\Dokumente\02 Arbeit\01 Projekte"
    DefaultTemplate = "D:\OneDrive\Dokumente\02 Arbeit\05 Vorlagen - Scripte"
}
Write-Debug "Systempfade erzeugt." -Prefix "Detect-System"

# ------------------------------------------------------------
# 💾 JSON-Datei lesen oder neu erstellen
# ------------------------------------------------------------
$configPath = Join-Path $rootPath "01_Config\Systeminfo.json"
$sysData = @{}

if (Test-Path $configPath) {
    try {
        $sysData = Get-Content $configPath -Raw | ConvertFrom-Json
        Write-Debug "Systeminfo.json geladen." -Prefix "Detect-System"
    } catch {
        Write-Host "⚠️  Fehler beim Lesen der Systeminfo.json – wird neu erstellt." -ForegroundColor Yellow
        Write-Debug "Fehler beim Lesen von Systeminfo.json: $($_.Exception.Message)" -Prefix "Detect-System"
        $sysData = @{}
    }
}

if (-not $sysData.Systeme) {
    $sysData = [PSCustomObject]@{ Systeme = @() }
    Write-Debug "Neues JSON-Objekt für Systeme erstellt." -Prefix "Detect-System"
}

# ------------------------------------------------------------
# 🔁 Prüfen, ob aktuelles System schon existiert
# ------------------------------------------------------------
$existing = $sysData.Systeme | Where-Object {
    $_.Benutzername -eq $userName -and $_.Computername -eq $computerName
}

if ($existing) {
    Write-Host "🔄 System bereits vorhanden – aktualisiere Eintrag..." -ForegroundColor Yellow
    Write-Debug "Bestehendes System gefunden – wird aktualisiert." -Prefix "Detect-System"

    $existing.Systempfade = $systemPaths
    $existing.ErkanntAm = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
} else {
    Write-Host "➕ Neues System erkannt – füge Eintrag hinzu..." -ForegroundColor Green
    Write-Debug "Neues System erkannt, wird hinzugefügt." -Prefix "Detect-System"

    $newEntry = [PSCustomObject]@{
        Benutzername   = $userName
        Computername   = $computerName
        System         = $osVersion
        ProfilPfad     = $userProfile
        ErkanntAm      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Systempfade    = $systemPaths
    }
    $sysData.Systeme += $newEntry
}

# ------------------------------------------------------------
# 💾 In JSON-Datei speichern
# ------------------------------------------------------------
try {
    $sysData | ConvertTo-Json -Depth 6 | Out-File -FilePath $configPath -Encoding UTF8
    Write-Host "`n✅ Systeminformationen aktualisiert unter:`n   $configPath" -ForegroundColor Green
    Write-Debug "Systeminfo.json erfolgreich gespeichert." -Prefix "Detect-System"
}
catch {
    Write-Host "`n❌ Fehler beim Schreiben der Systeminfo.json:`n$_" -ForegroundColor Red
    Write-Debug "Fehler beim Schreiben von Systeminfo.json: $($_.Exception.Message)" -Prefix "Detect-System"
}

Write-Host "`n✅ Systemerkennung abgeschlossen.`n" -ForegroundColor Green
Write-Debug "Systemerkennung abgeschlossen." -Prefix "Detect-System"
Start-Sleep -Seconds 1
