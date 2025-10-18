# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.0.5
# Zweck:   Auswahl zwischen neuer Baustelle und Projektliste
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
Write-Host "3️⃣  Abbrechen"
Write-Host ""

$wahl = Read-Host "Bitte Auswahl eingeben (1–3)"

switch ($wahl) {
    "1" {
        Write-Host "`n➡️  Starte Neuanlage einer Baustelle..."
        # --------------------------------------------------------
        # 🔽 Alter Code: Neue Baustelle anlegen
        # --------------------------------------------------------
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
                Status = "Neu"
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

        # Prüfen ob Projekte-Property existiert
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

        # Neuen Projekteintag hinzufügen
        $newProject = [PSCustomObject]@{
            Name   = $projektName
            Status = "Neu"
            Datum  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Pfad   = $sysInfo.Systempfade.RootPath
        }

        $pcNode.Projekte += $newProject
        Save-JsonFile -Data $data -Path $projektListePath

        Write-Host "`n✅ Projekt '$projektName' wurde erfolgreich hinzugefügt."
        Write-Host "📄 Gespeichert in: $projektListePath"
    }

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
                        Write-Host ("   • {0,-20} | {1,-19} | {2}" -f $p.Name, $p.Status, $p.Datum)
                    }
                }
                else {
                    Write-Host "   (Keine Projekte vorhanden)" -ForegroundColor DarkGray
                }
            }
        }
    }

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
