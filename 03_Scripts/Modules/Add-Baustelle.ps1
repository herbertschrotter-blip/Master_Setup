# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.0.6
# Zweck:   Verwaltung der Projektliste (Neue Baustelle, Liste anzeigen, Status ändern)
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
# 📋 Menüauswahl
# ------------------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Gray
Write-Host "🏗️  ADD-BAUSTELLE – PROJEKTVERWALTUNG" -ForegroundColor Cyan
Write-Host "============================================="
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

        $projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"
        $data = Get-JsonFile -Path $projektListePath -CreateIfMissing

        # Wenn Datei leer → erste Anlage inklusive Projekt
        if (-not $data -or $data.Count -eq 0) {
            Write-Host "ℹ️  Erstelle neue Projektliste-Struktur..."
            $newProject = [PSCustomObject]@{
                Name   = $projektName
                Status = "Aktiv"
                Datum  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                Pfad   = $sysInfo.Systempfade.RootPath
            }

            $data = @(
                @{
                    Benutzer = @{
                        ($sysInfo.Benutzername) = @{
                            ($sysInfo.Computername) = @{
                                Projekte = @($newProject)
                            }
                        }
                    }
                }
            )

            Save-JsonFile -Data $data -Path $projektListePath
            Write-Host "✅ Projektliste neu erstellt und Projekt '$projektName' hinzugefügt."
            Write-Host "📄 Gespeichert in: $projektListePath"
            return
        }

        # Benutzer/Computer-Knoten prüfen
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

        # Prüfen, ob Property 'Projekte' existiert
        if (-not ($pcNode.PSObject.Properties.Name -contains "Projekte")) {
            Add-Member -InputObject $pcNode -MemberType NoteProperty -Name "Projekte" -Value @()
        }

        # Prüfen auf Duplikat
        foreach ($p in $pcNode.Projekte) {
            if ($p.Name -eq $projektName) {
                Write-Host "⚠️  Projekt '$projektName' existiert bereits." -ForegroundColor Yellow
                return
            }
        }

        # Neues Projekt hinzufügen
        $newProject = [PSCustomObject]@{
            Name   = $projektName
            Status = "Aktiv"
            Datum  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Pfad   = $sysInfo.Systempfade.RootPath
        }

        $pcNode.Projekte += $newProject
        Save-JsonFile -Data $data -Path $projektListePath

        Write-Host "`n✅ Projekt '$projektName' wurde erfolgreich hinzugefügt."
        Write-Host "📄 Gespeichert in: $projektListePath"
    }

    # ------------------------------------------------------------
    # 2️⃣ Projektliste anzeigen
    # ------------------------------------------------------------
    "2" {
        Write-Host "`n📋  Projektliste anzeigen`n"
        $projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"
        if (-not (Test-Path $projektListePath)) {
            Write-Host "⚠️  Keine Projektliste gefunden. Bitte zuerst eine Baustelle anlegen." -ForegroundColor Yellow
            return
        }

        $data = Get-JsonFile -Path $projektListePath
        if ($data.Count -eq 0) {
            Write-Host "📭  Die Projektliste ist leer."
            return
        }

        foreach ($benutzer in $data[0].Benutzer.PSObject.Properties.Name) {
            Write-Host "👤 Benutzer: $benutzer" -ForegroundColor Cyan
            foreach ($computer in $data[0].Benutzer.$benutzer.PSObject.Properties.Name) {
                Write-Host "💻 Computer: $computer" -ForegroundColor Gray
                $projekte = $data[0].Benutzer.$benutzer.$computer.Projekte
                if ($projekte) {
                    foreach ($p in $projekte) {
                        Write-Host ("   • {0,-25} | {1,-13} | {2}" -f $p.Name, $p.Status, $p.Datum)
                    }
                }
                else {
                    Write-Host "   (Keine Projekte vorhanden)" -ForegroundColor DarkGray
                }
            }
        }
    }

    # ------------------------------------------------------------
    # 3️⃣ Projektstatus ändern
    # ------------------------------------------------------------
    "3" {
        Write-Host "`n🛠️  Projektstatus ändern`n"

        $projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"
        if (-not (Test-Path $projektListePath)) {
            Write-Host "⚠️  Keine Projektliste gefunden. Bitte zuerst eine Baustelle anlegen." -ForegroundColor Yellow
            return
        }

        $data = Get-JsonFile -Path $projektListePath
        $benutzer = $sysInfo.Benutzername
        $computer = $sysInfo.Computername
        $projekte = $data[0].Benutzer.$benutzer.$computer.Projekte

        if (-not $projekte -or $projekte.Count -eq 0) {
            Write-Host "📭  Keine Projekte vorhanden." -ForegroundColor Yellow
            return
        }

        Write-Host "📋  Vorhandene Projekte:`n"
        for ($i = 0; $i -lt $projekte.Count; $i++) {
            $p = $projekte[$i]
            Write-Host ("[{0}] {1,-25} | Status: {2}" -f $i, $p.Name, $p.Status)
        }

        $index = Read-Host "`n🔢  Bitte Projektnummer auswählen"
        if ($index -notmatch '^\d+$' -or [int]$index -ge $projekte.Count) {
            Write-Host "⚠️  Ungültige Auswahl." -ForegroundColor Yellow
            return
        }

        $newStatus = Read-Host "Neuen Status eingeben (aktiv/abgeschlossen)"
        if ($newStatus -notin @("aktiv","abgeschlossen")) {
            Write-Host "⚠️  Ungültiger Status – nur 'aktiv' oder 'abgeschlossen' erlaubt." -ForegroundColor Yellow
            return
        }

        $projekte[$index].Status = (Get-Culture).TextInfo.ToTitleCase($newStatus)
        Save-JsonFile -Data $data -Path $projektListePath
        Write-Host "`n✅ Status von Projekt '$($projekte[$index].Name)' wurde geändert auf '$($projekte[$index].Status)'."
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
