# ============================================================
# Modul: Add-Baustelle.ps1
# Version: MOD_V1.1.3
# Zweck:   Systemunabhängige Projektliste mit Benutzer-/Computerinfos
# Autor:   Herbert Schrotter
# Datum:   19.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systeminformationen & Libraries laden
# ------------------------------------------------------------
try {
    . "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"
    . "$PSScriptRoot\..\Libs\Lib_Json.ps1"
    . "$PSScriptRoot\..\Libs\Lib_Menu.ps1"
    $sysInfo = Get-SystemInfo
}
catch {
    Write-Host "❌ Fehler beim Laden benötigter Bibliotheken: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# ------------------------------------------------------------
# 🧩 Funktionen
# ------------------------------------------------------------

function Add-NewProject {
    Write-Host "`n➡️  Starte Neuanlage einer Baustelle..."
    $projektName = Read-Host "🏗️  Bitte Projektnamen eingeben (z. B. 25-10 Testprojekt)"
    if ([string]::IsNullOrWhiteSpace($projektName)) {
        Write-Host "⚠️  Kein Projektname eingegeben – Vorgang abgebrochen." -ForegroundColor Yellow
        return
    }

    $data = Get-JsonFile -Path $projektListePath -CreateIfMissing
    if (-not $data -or -not $data.Projekte) { $data = @{ Projekte = @() } }

    if ($data.Projekte | Where-Object { $_.Name -eq $projektName }) {
        Write-Host "⚠️  Projekt '$projektName' existiert bereits." -ForegroundColor Yellow
        return
    }

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

function Show-ProjectList {
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

    $fmtHeader = "{0,-28} | {1,-12} | {2,-10}"
    $fmtRow    = "- {0,-28} | {1,-12} | {2,-10}"

    Write-Host ($fmtHeader -f "Projekt", "Status", "Datum") -ForegroundColor Gray
    Write-Host ("-" * 28 + "-+-" + "-" * 12 + "-+-" + "-" * 10)

    foreach ($p in $data.Projekte) {
        $name = [string]$p.Name
        if ($name.Length -gt 28) { $name = $name.Substring(0,27) + "…" }
        $status = [string]$p.Status
        $datumKurz = ([string]$p.Datum).Split(" ")[0]
        Write-Host ($fmtRow -f $name, $status, $datumKurz)
    }
}

function Change-ProjectStatus {
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
    $fmtRowSel = "[{0}] {1,-25} | Status: {2}"
    for ($i = 0; $i -lt $data.Projekte.Count; $i++) {
        $p = $data.Projekte[$i]
        $name = [string]$p.Name
        if ($name.Length -gt 25) { $name = $name.Substring(0,24) + "…" }
        Write-Host ($fmtRowSel -f $i, $name, $p.Status)
    }

    $index = Read-Host "`n🔢  Bitte Projektnummer auswählen"
    if ($index -notmatch '^\d+$' -or [int]$index -ge $data.Projekte.Count) {
        Write-Host "⚠️  Ungültige Auswahl." -ForegroundColor Yellow
        return
    }

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
# 🪲 DebugMode-Hinweis
# ------------------------------------------------------------
if (Get-DebugMode) {
    Write-Host "🪲 DEBUG-MODE AKTIVIERT" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# 📊 Status-Zusammenfassung & dynamisches Menü
# ------------------------------------------------------------
$projektListePath = Join-Path -Path $sysInfo.Systempfade.RootPath -ChildPath "01_Config\Projektliste.json"

while ($true) {
    # Aktuelle Statuswerte zählen
    $aktiveCount = 0; $abgeschlCount = 0
    if (Test-Path $projektListePath) {
        try {
            $data = Get-JsonFile -Path $projektListePath
            foreach ($p in $data.Projekte) {
                if ($p.Status -eq "Aktiv") { $aktiveCount++ }
                elseif ($p.Status -eq "Abgeschlossen") { $abgeschlCount++ }
            }
        } catch {
            Write-Host "⚠️  Konnte Projektliste nicht auslesen." -ForegroundColor Yellow
        }
    }

    # Menü anzeigen mit aktualisiertem Titel
    $menuTitle = "🏗️  PROJEKTVERWALTUNG`n📊 Aktive: $aktiveCount | Abgeschlossene: $abgeschlCount"

    $choice = Show-SubMenu -MenuTitle $menuTitle -Options @{
        "1" = "Neue Baustelle anlegen|Add-NewProject"
        "2" = "Projektliste anzeigen|Show-ProjectList"
        "3" = "Projektstatus ändern|Change-ProjectStatus"
    } -ReturnAfterAction

    if ($choice -eq "0") { break }
}

# ------------------------------------------------------------
# 🔙 Rückkehr zum Master Controller
# ------------------------------------------------------------
try {
    $masterPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Master_Controller.ps1")
    if (Test-Path $masterPath) {
        & $masterPath
        exit
    } else {
        Write-Host "⚠️  Master_Controller.ps1 nicht gefunden – bitte manuell starten." -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Fehler beim Rücksprung in Master_Controller: $($_.Exception.Message)" -ForegroundColor Red
}
