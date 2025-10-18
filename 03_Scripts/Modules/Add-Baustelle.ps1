# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.1.0
# Zweck:   Systemunabhängige Projektliste mit Benutzer-/Computerinfos
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
# 📊 Status-Zusammenfassung laden
# ------------------------------------------------------------
$projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"
$aktiveCount = 0
$abgeschlCount = 0

if (Test-Path $projektListePath) {
    try {
        $data = Get-JsonFile -Path $projektListePath
        if ($data.Projekte) {
            foreach ($p in $data.Projekte) {
                if ($p.Status -eq "Aktiv") { $aktiveCount++ }
                elseif ($p.Status -eq "Abgeschlossen") { $abgeschlCount++ }
            }
        }
    }
    catch {
        Write-Host "⚠️  Konnte Projektliste nicht auslesen." -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------
# 📋 Menüauswahl
# ------------------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Gray
Write-Host "🏗️  ADD-BAUSTELLE – PROJEKTVERWALTUNG" -ForegroundColor Cyan
Write-Host "============================================="
if (Test-Path $projektListePath) {
    Write-Host ("📊 Aktive Projekte: {0} | Abgeschlossene: {1}" -f $aktiveCount, $abgeschlCount) -ForegroundColor DarkCyan
}
else {
    Write-Host "📊 Noch keine Projektliste vorhanden." -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "1️⃣  Neue Baustelle anlegen"
Write-Host "2️⃣  Projektliste anzeigen"
Write-Host "3️⃣  Projektstatus ändern"
Write-Host "4️⃣  Abbrechen"
Write-Host ""

$wahl = Read-Host "Bitte Auswahl eingeben (1–4)"

switch ($wahl) {

    # ------------------------------------------------------------
    # 1️⃣ Neue Baustelle anlegen
    # ------------------------------------------------------------
    "1" {
        Write-Host "`n➡️  Starte Neuanlage einer Baustelle..."
        $projektName = Read-Host "🏗️  Bitte Projektnamen eingeben (z. B. 25-10 Testprojekt)"
        if ([string]::IsNullOrWhiteSpace($projektName)) {
            Write-Host "⚠️  Kein Projektname eingegeben – Vorgang abgebrochen." -ForegroundColor Yellow
            return
        }

        # Bestehende oder neue Daten laden
        $data = Get-JsonFile -Path $projektListePath -CreateIfMissing
        if (-not $data -or -not $data.Projekte) {
            $data = @{ Projekte = @() }
        }

        # Duplikatsprüfung
        if ($data.Projekte | Where-Object { $_.Name -eq $projektName }) {
            Write-Host "⚠️  Projekt '$projektName' existiert bereits." -ForegroundColor Yellow
            return
        }

        # Neues Projekt anlegen
        $newProject = [PSCustomObject]@{
            Name   = $projektName
            Status = "Aktiv"
            Datum  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Info   = [PSCustomObject]@{
                Benutzer = $sysInfo.Benutzername
                Computer = $sysInfo.Computername
                Pfad     = $sysInfo.Systempfade.RootPath
            }
        }

        $data.Projekte += $newProject
        Save-JsonFile -Data $data -Path $projektListePath

        Write-Host "`n✅ Projekt '$projektName' wurde erfolgreich hinzugefügt."
        Write-Host "📄 Gespeichert in: $projektListePath"
    }

    # ------------------------------------------------------------
    # 2️⃣ Projektliste anzeigen
    # ------------------------------------------------------------
    "2" {
        Write-Host "`n📋  Projektliste anzeigen`n"
        if (-not (Test-Path $projektListePath)) {
            Write-Host "⚠️  Keine Projektliste gefunden. Bitte zuerst eine Baustelle anlegen." -ForegroundColor Yellow
            return
        }

        $data = Get-JsonFile -Path $projektListePath
        if (-not $data.Projekte -or $data.Projekte.Count -eq 0) {
            Write-Host "📭  Die Projektliste ist leer."
            return
        }

        foreach ($p in $data.Projekte) {
            # Nur Datum (ohne Uhrzeit)
            $datumKurz = ($p.Datum -split ' ')[0]
            Write-Host ("• {0,-25} | {1,-10} | {2}" -f $p.Name, $p.Status, $datumKurz)
        }
    }

    # ------------------------------------------------------------
    # 3️⃣ Projektstatus ändern
    # ------------------------------------------------------------
    "3" {
        Write-Host "`n🛠️  Projektstatus ändern`n"
        if (-not (Test-Path $projektListePath)) {
            Write-Host "⚠️  Keine Projektliste gefunden. Bitte zuerst eine Baustelle anlegen." -ForegroundColor Yellow
            return
        }

        $data = Get-JsonFile -Path $projektListePath
        if (-not $data.Projekte -or $data.Projekte.Count -eq 0) {
            Write-Host "📭  Keine Projekte vorhanden." -ForegroundColor Yellow
            return
        }

        Write-Host "📋  Vorhandene Projekte:`n"
        for ($i = 0; $i -lt $data.Projekte.Count; $i++) {
            $p = $data.Projekte[$i]
            $indexStr = ("[{0}]" -f $i).PadRight(5)
         Write-Host ("{0}{1,-25} | Status: {2}" -f $indexStr, $p.Name, $p.Status)
}

        $index = Read-Host "`n🔢  Bitte Projektnummer auswählen"
        if ($index -notmatch '^\d+$' -or [int]$index -ge $data.Projekte.Count) {
            Write-Host "⚠️  Ungültige Auswahl." -ForegroundColor Yellow
            return
        }

        # Menübasierte Statusauswahl
        Write-Host "`nStatus ändern auf:"
        Write-Host "1️⃣  Aktiv"
        Write-Host "2️⃣  Abgeschlossen"
        $statusWahl = Read-Host "Bitte Auswahl eingeben (1–2)"

        switch ($statusWahl) {
            "1" { $newStatus = "Aktiv" }
            "2" { $newStatus = "Abgeschlossen" }
            default {
                Write-Host "⚠️  Ungültige Auswahl. Vorgang abgebrochen." -ForegroundColor Yellow
                return
            }
        }

        $data.Projekte[$index].Status = $newStatus
        Save-JsonFile -Data $data -Path $projektListePath
        Write-Host "`n✅ Status von Projekt '$($data.Projekte[$index].Name)' wurde geändert auf '$newStatus'."
    }

    # ------------------------------------------------------------
    # 4️⃣ Abbrechen
    # ------------------------------------------------------------
    default {
        Write-Host "`n🚪 Vorgang abgebrochen."
        return
    }
}

# ------------------------------------------------------------
# 🏁 Ende
# ------------------------------------------------------------
Write-Host "`nFertig. Drücke eine Taste zum Beenden ..."
[void][System.Console]::ReadKey($true)
