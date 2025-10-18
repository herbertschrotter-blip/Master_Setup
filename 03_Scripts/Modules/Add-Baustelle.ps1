# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.0.1
# Zweck:   Neue Baustelle anlegen (nur Name + Projektliste.json)
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
# 🧩 Pfad zur Projektliste festlegen
# ------------------------------------------------------------
$projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"

# ------------------------------------------------------------
# 📦 Neuer Eintrag vorbereiten
# ------------------------------------------------------------
$newEntry = [PSCustomObject]@{
    Datum        = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Projektname  = $projektName
    Benutzer     = $sysInfo.Benutzername
    Computer     = $sysInfo.Computername
    RootPfad     = $sysInfo.Systempfade.RootPath
}

# ------------------------------------------------------------
# 💾 Eintrag in Projektliste.json schreiben oder ergänzen
# ------------------------------------------------------------
try {
    if (Test-Path $projektListePath) {
        # Bestehende Datei laden und erweitern
        $projektData = Get-Content $projektListePath -Raw | ConvertFrom-Json
        if (-not $projektData -or -not ($projektData -is [System.Collections.IEnumerable])) {
            $projektData = @()
        }
        $projektData += $newEntry
    }
    else {
        # Neue Datei erstellen
        $projektData = @($newEntry)
    }

    # Speichern als JSON (UTF8 ohne BOM)
    $projektData | ConvertTo-Json -Depth 4 | Set-Content -Path $projektListePath -Encoding utf8

    Write-Host "`n✅ Neuer Projekteintrag wurde erfolgreich in 'Projektliste.json' gespeichert."
    Write-Host "📄 Pfad: $projektListePath"
}
catch {
    Write-Host "❌ Fehler beim Schreiben der Projektliste.json: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------------------------------------------------
# 🏁 Ende
# ------------------------------------------------------------
Write-Host "`nFertig. Drücke eine Taste zum Beenden ..."
[void][System.Console]::ReadKey($true)
