# ============================================================
# Library: Lib_Json.ps1
# Version: LIB_V1.0.3
# Zweck:   Universelle JSON-Lese-, Schreib- und Erstellfunktionen
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 DebugMode-Unterstützung (optional)
# ------------------------------------------------------------
# Wenn Lib_Systeminfo.ps1 geladen ist, werden Debugmeldungen
# automatisch berücksichtigt.
# ------------------------------------------------------------
function Write-DebugMsg {
    param([string]$Text)
    try {
        if (Get-Command Get-DebugMode -ErrorAction SilentlyContinue) {
            if (Get-DebugMode) {
                Write-Host "🪲 $Text" -ForegroundColor DarkYellow
            }
        }
    } catch {}
}

# ------------------------------------------------------------
# 📖 Funktion: Get-JsonFile
# Zweck:   Liest eine JSON-Datei und gibt deren Inhalt als Objekt zurück.
# Parameter:
#   -Path            → Pfad zur JSON-Datei
#   -CreateIfMissing → erstellt leere Datei, wenn sie fehlt
# Rückgabe:
#   PowerShell-Objekt (oder leeres Array bei Fehler)
# ------------------------------------------------------------
function Get-JsonFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [switch]$CreateIfMissing
    )

    try {
        # Datei ggf. neu erstellen
        if (-not (Test-Path $Path)) {
            if ($CreateIfMissing) {
                Write-DebugMsg "Erstelle neue JSON-Datei: ${Path}"
                @() | ConvertTo-Json -Depth 4 | Set-Content -Path $Path -Encoding utf8
            }
            else {
                throw "Datei nicht gefunden: ${Path}"
            }
        }

        # Inhalt lesen
        $content = Get-Content $Path -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($content)) {
            Write-DebugMsg "Leere JSON-Datei erkannt: ${Path} → Rückgabe leeres Array"
            return @()
        }

        $json = $content | ConvertFrom-Json -ErrorAction Stop
        Write-DebugMsg "JSON erfolgreich geladen: ${Path}"
        return ,$json
    }
    catch {
        Write-Host "❌ Fehler beim Lesen von ${Path}: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

# ------------------------------------------------------------
# 💾 Funktion: Save-JsonFile
# Zweck:   Speichert ein beliebiges Objekt als JSON-Datei.
# Parameter:
#   -Data → Objekt oder Array, das gespeichert werden soll
#   -Path → Zielpfad der JSON-Datei
# ------------------------------------------------------------
function Save-JsonFile {
    param(
        [Parameter(Mandatory)][object]$Data,
        [Parameter(Mandatory)][string]$Path
    )

    try {
        # Sicherstellen, dass Zielverzeichnis existiert
        $dir = Split-Path $Path
        if (-not (Test-Path $dir)) {
            Write-DebugMsg "Erstelle Zielverzeichnis: ${dir}"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        # Speichern mit UTF8 (ohne BOM)
        $Data | ConvertTo-Json -Depth 8 | Set-Content -Path $Path -Encoding utf8
        Write-DebugMsg "JSON gespeichert: ${Path}"
    }
    catch {
        Write-Host "❌ Fehler beim Schreiben von ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# ➕ Funktion: Add-JsonEntry
# Zweck:   Fügt einen neuen Datensatz zu einer JSON-Datei hinzu.
# Parameter:
#   -Path  → Pfad der Datei
#   -Entry → Objekt, das angehängt werden soll
# ------------------------------------------------------------
function Add-JsonEntry {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][object]$Entry
    )

    try {
        $jsonData = Get-JsonFile -Path $Path -CreateIfMissing

        # Sicherstellen, dass es ein Array ist
        if (-not ($jsonData -is [System.Collections.IEnumerable]) -or ($jsonData -is [string])) {
            Write-DebugMsg "Konvertiere vorhandene JSON-Daten in Array."
            $jsonData = @($jsonData)
        }

        # Wenn leer oder fehlerhaft
        if ($jsonData.Count -eq 0 -or ($jsonData.Count -eq 1 -and -not $jsonData[0])) {
            Write-DebugMsg "Leere JSON-Datei erkannt → neues Array erstellt."
            $jsonData = @()
        }

        # Eintrag anhängen
        $jsonData += $Entry

        # Speichern
        Save-JsonFile -Data $jsonData -Path $Path
        Write-DebugMsg "Eintrag zu JSON-Datei hinzugefügt: ${Path}"
    }
    catch {
        Write-Host "❌ Fehler beim Hinzufügen zu ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 🔄 Funktion: Update-JsonValue
# Zweck:   Aktualisiert gezielt einen Wert in einer JSON-Datei.
# Beispiel:
#   Update-JsonValue -Path $p -Key "DebugMode" -Value $false
# ------------------------------------------------------------
function Update-JsonValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][object]$Value
    )

    try {
        $json = Get-JsonFile -Path $Path -CreateIfMissing
        if ($null -eq $json) { $json = @{} }

        if ($json.PSObject.Properties.Name -contains $Key) {
            Write-DebugMsg "Aktualisiere bestehenden Schlüssel '${Key}' in ${Path}"
            $json.$Key = $Value
        }
        else {
            Write-DebugMsg "Füge neuen Schlüssel '${Key}' hinzu in ${Path}"
            Add-Member -InputObject $json -NotePropertyName $Key -NotePropertyValue $Value
        }

        Save-JsonFile -Data $json -Path $Path
    }
    catch {
        Write-Host "❌ Fehler beim Aktualisieren von ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# ❌ Funktion: Remove-JsonEntry
# Zweck:   Löscht Einträge in JSON-Arrays anhand eines Feldwerts.
# Beispiel:
#   Remove-JsonEntry -Path $p -Key "Projektname" -Value "Testprojekt"
# ------------------------------------------------------------
function Remove-JsonEntry {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Value
    )

    try {
        $jsonData = Get-JsonFile -Path $Path -CreateIfMissing
        if (-not ($jsonData -is [System.Collections.IEnumerable])) {
            Write-Host "⚠️ JSON-Datei enthält keine Liste: ${Path}" -ForegroundColor Yellow
            return
        }

        $beforeCount = $jsonData.Count
        $jsonData = $jsonData | Where-Object { $_.$Key -ne $Value }
        $afterCount = $jsonData.Count

        Save-JsonFile -Data $jsonData -Path $Path
        Write-DebugMsg "Entfernt $($beforeCount - $afterCount) Eintrag(e) aus ${Path}"
    }
    catch {
        Write-Host "❌ Fehler beim Entfernen aus ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}
