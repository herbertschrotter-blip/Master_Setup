# ============================================================
# Modul: Detect-System.ps1
# Version: MOD_V1.0.0
# Zweck:   Erkennt Benutzer- und Systeminformationen
#          und legt dynamische Projektpfade je System an.
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

Write-Host "`n👤 Benutzer:  $userName"
Write-Host "🖥️  Computer: $computerName"
Write-Host "💽 System:    $osVersion`n"

# ------------------------------------------------------------
# 📁 Projektpfade dynamisch aufbauen
# ------------------------------------------------------------
$projectPaths = [ordered]@{
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
# 🧩 Struktur für JSON
# ------------------------------------------------------------
$systemData = [PSCustomObject]@{
    Benutzername   = $userName
    Computername   = $computerName
    System         = $osVersion
    ProfilPfad     = $userProfile
    ErkanntAm      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Projektpfade   = $projectPaths
}

# ------------------------------------------------------------
# 💾 In JSON-Datei speichern
# ------------------------------------------------------------
$configPath = Join-Path $rootPath "01_Config\Systeminfo.json"

try {
    $systemData | ConvertTo-Json -Depth 5 | Out-File -FilePath $configPath -Encoding UTF8
    Write-Host "`n✅ System- und Benutzerinfos gespeichert unter:`n   $configPath" -ForegroundColor Green
}
catch {
    Write-Host "`n⚠️  Fehler beim Schreiben der JSON-Datei:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}

# ------------------------------------------------------------
# 🧾 Kurze Vorschau
# ------------------------------------------------------------
Write-Host "`n📋 Zusammenfassung:" -ForegroundColor Cyan
$projectPaths.GetEnumerator() | ForEach-Object {
    Write-Host ("   📂 " + $_.Key.PadRight(15) + " → " + $_.Value) -ForegroundColor White
}

Write-Host "`n✅ Systemerkennung abgeschlossen.`n" -ForegroundColor Green
Start-Sleep -Seconds 2
