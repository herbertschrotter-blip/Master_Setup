# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.0.4
# Zweck:   Neue Baustelle anlegen (Projekte gruppiert nach Benutzer/Computer)
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systeminformationen laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
    $sysInfo = Get-SystemInfo
}
catch {
    Write-Host "❌ Fehler beim Laden der Systeminformationen: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# ------------------------------------------------------------
# 🧩 JSON-Library laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\..\Libs\Lib_Json.ps1"
}
catch {
    Write-Host "❌ Fehler beim Laden der Lib_Json.ps1: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# ------------------------------------------------------------
# 🧾 DebugMode-Anzeige
# ------------------------------------------------------------
if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# 🔤 Projektnamen abfragen
# ------------------------------------------------------------
$projektName = Read-Host "🏗️  Bitte Projektnamen eingeben (z. B. 25-10 Testprojekt)"
if ([string]::IsNullOrWhiteSpace($projektName)) {
    Write-Host "⚠️  Kein Projektname eingegeben – Vorgang abgebrochen." -ForegroundColor Yellow
    return
}

# ------------------------------------------------------------
# 📄 Pfad zur Projektliste definieren
# ------------------------------------------------------------
$projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"

# ------------------------------------------------------------
# 🧱 Bestehende Liste laden oder Grundstruktur anlegen
# ------------------------------------------------------------
$data = Get-JsonFile -Path $projektListePath -CreateIfMissing

if (-not $data -or $data.Count -eq 0) {
    $data = @(
        @{
            Benutzer = @{
                ($sysInfo.Benutzername) = @{
                    ($sysInfo.Computername) = @{
                        Projekte = @()
                    }
                }
            }
        }
    )
}

# Benutzer- und Computer-Node referenzieren oder anlegen
$userNode = $data[0].Benutzer.$($sysInfo.Benutzername)
if (-not $userNode) {
    $data[0].Benutzer.$($sysInfo.Benutzername) = @{}
    $userNode = $data[0].Benutzer.$($sysInfo.Benutzername)
}

$pcNode = $userNode.$($sysInfo.Computername)
if (-not $pcNode) {
    $userNode.$($sysInfo.Computername) = @{ Projekte = @() }
    $pcNode = $userNode.$($sysInfo.Computername)
}

# ------------------------------------------------------------
# 🔍 Prüfen, ob Projekt bereits existiert
# ------------------------------------------------------------
$exists = $false
foreach ($p in $pcNode.Projekte) {
    if ($p.Name -eq $projektName) {
        $exists = $true
        break
    }
}

if ($exists) {
    Write-Host "⚠️  Projekt '$projektName' existiert bereits auf diesem System." -ForegroundColor Yellow
    return
}

# ------------------------------------------------------------
# 🧩 Neuen Projekteintag hinzufügen (Fix für fehlende Property)
# ------------------------------------------------------------
$newProject = [PSCustomObject]@{
    Name   = $projektName
    Status = "Neu"
    Datum  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Pfad   = $sysInfo.Systempfade.RootPath
}

# Prüfen, ob 'Projekte' vorhanden ist – wenn nicht, hinzufügen
if (-not ($pcNode.PSObject.Properties.Name -contains "Projekte")) {
    Add-Member -InputObject $pcNode -MemberType NoteProperty -Name "Projekte" -Value @()
}

# Jetzt sicher anhängen
$pcNode.Projekte += $newProject

# ------------------------------------------------------------
# 💾 Speichern
# ------------------------------------------------------------
try {
    Save-JsonFile -Data $data -Path $projektListePath
    Write-Host "`n✅ Projekt '$projektName' wurde erfolgreich hinzugefügt."
    Write-Host "📄 Gespeichert in: $projektListePath"
}
catch {
    Write-Host "❌ Fehler beim Speichern: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------
# 🏁 Ende
# ------------------------------------------------------------
Write-Host "`nFertig. Drücke eine Taste zum Beenden ..."
[void][System.Console]::ReadKey($true)
