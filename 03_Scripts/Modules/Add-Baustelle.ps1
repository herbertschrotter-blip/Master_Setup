# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.0.2
# Zweck:   Neue Baustelle anlegen (Name + Projektliste.json über Lib_Json)
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
# 🧱 Prüfen, ob Projekt bereits existiert
# ------------------------------------------------------------
$projektListe = Get-JsonFile -Path $projektListePath -CreateIfMissing
$exists = $false
foreach ($p in $projektListe) {
    if ($p.Projektname -eq $projektName) {
        $exists = $true
        break
    }
}

if ($exists) {
    Write-Host "⚠️  Projekt '$projektName' existiert bereits in der Projektliste.json" -ForegroundColor Yellow
    return
}

# ------------------------------------------------------------
# 🧩 Neuen Eintrag vorbereiten
# ------------------------------------------------------------
$newEntry = [PSCustomObject]@{
    Datum        = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Projektname  = $projektName
    Benutzer     = $sysInfo.Benutzername
    Computer     = $sysInfo.Computername
    RootPfad     = $sysInfo.Systempfade.RootPath
}

# ------------------------------------------------------------
# 💾 Eintrag in Projektliste.json hinzufügen
# ------------------------------------------------------------
try {
    Add-JsonEntry -Path $projektListePath -Entry $newEntry
    Write-Host "`n✅ Neuer Projekteintrag wurde erfolgreich in 'Projektliste.json' gespeichert."
    Write-Host "📄 Pfad: $projektListePath"
}
catch {
    Write-Host "❌ Fehler beim Hinzufügen zur Projektliste: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------
# 🏁 Ende
# ------------------------------------------------------------
Write-Host "`nFertig. Drücke eine Taste zum Beenden ..."
[void][System.Console]::ReadKey($true)
