# ============================================================
# Modul: Detect-System.ps1
# Version: MOD_V1.1.0
# Zweck:   Erkennt Benutzer- und Systeminformationen
#          und speichert bzw. aktualisiert Systeminfo.json (Multi-System-Support)
# Autor:   Herbert Schrotter
# Datum:   17.10.2025
# ============================================================

param()

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     💻 SYSTEM- UND BENUTZERERKENNUNG         " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 🔍 Benutzer- und Systeminfos ermitteln
# ------------------------------------------------------------
$userName     = $env:USERNAME
$computerName = $env:COMPUTERNAME
$userProfile  = $env:USERPROFILE
$osVersion    = (Get-CimInstance Win32_OperatingSystem).Caption
$rootPath     = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

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

# ------------------------------------------------------------
# 💾 JSON-Datei lesen oder neu erstellen
# ------------------------------------------------------------
$configPath = Join-Path $rootPath "01_Config\Systeminfo.json"
$sysData = @{}

if (Test-Path $configPath) {
    try {
        $sysData = Get-Content $configPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "⚠️  Fehler beim Lesen der Systeminfo.json – wird neu erstellt." -ForegroundColor Yellow
        $sysData = @{}
    }
}

if (-not $sysData.Systeme) {
    $sysData = [PSCustomObject]@{ Systeme = @() }
}

# ------------------------------------------------------------
# 🔁 Prüfen, ob aktuelles System schon existiert
# ------------------------------------------------------------
$existing = $sysData.Systeme | Where-Object {
    $_.Benutzername -eq $userName -and $_.Computername -eq $computerName
}

if ($existing) {
    Write-Host "🔄 System bereits vorhanden – aktualisiere Eintrag..." -ForegroundColor Yellow
    $existing.Systempfade = $systemPaths
    $existing.ErkanntAm = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
} else {
    Write-Host "➕ Neues System erkannt – füge Eintrag hinzu..." -ForegroundColor Green
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
}
catch {
    Write-Host "`n❌ Fehler beim Schreiben der Systeminfo.json:`n$_" -ForegroundColor Red
}

Write-Host "`n✅ Systemerkennung abgeschlossen.`n" -ForegroundColor Green
Start-Sleep -Seconds 1
