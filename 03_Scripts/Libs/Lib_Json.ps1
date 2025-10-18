# ============================================================
# Library: Lib_Json.ps1
# Version: LIB_V1.0.1
# Zweck:   Einheitliche JSON-Lese-, Schreib- und Erstellfunktionen
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systemintegration (DebugMode)
# ------------------------------------------------------------
# Diese Library nutzt optional Get-DebugMode aus Lib_Systeminfo.ps1,
# um Debugmeldungen anzuzeigen, falls der DebugMode aktiv ist.
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
        if (-not (Test-Path $Path)) {
            if ($CreateIfMissing) {
                Write-DebugMsg "Erstelle neue JSON-Datei: ${Path}"
                @() | ConvertTo-Json -Depth 4 | Set-Content -Path $Path -Encoding utf8
            }
            else {
                throw "Datei nicht gefunden: ${Path}"
            }
        }

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
# Zweck:   Speichert ein PowerShell-Objekt als JSON-Datei.
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
        # Zielverzeichnis sicherstellen
        $dir = Split-Path $Path
        if (-not (Test-Path $dir)) {
            Write-DebugMsg "Erstelle Zielverzeichnis: ${dir}"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        $Data | ConvertTo-Json -Depth 6 | Set-Content -Path $Path -Encoding utf8
        Write-DebugMsg "JSON gespeichert: ${Path}"
    }
    catch {
        Write-Host "❌ Fehler beim Schreiben von ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 🧩 Funktion: Add-JsonEntry
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
        if (-not ($jsonData -is [System.Collections.IEnumerable])) {
            $jsonData = @()
        }

        $jsonData += $Entry
        Save-JsonFile -Data $jsonData -Path $Path
        Write-DebugMsg "Eintrag zu JSON-Datei hinzugefügt: ${Path}"
    }
    catch {
        Write-Host "❌ Fehler beim Hinzufügen zu ${Path}: $($_.Exception.Message)" -ForegroundColor Red
    }
}
