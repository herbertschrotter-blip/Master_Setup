# ============================================================
# Library: Lib_Debug.ps1
# Version: LIB_V1.0.0
# Zweck:   Einheitliche Debug-Ausgabe und Logdateien
# Autor:   Herbert Schrotter
# Datum:   18.10.2025
# ============================================================

# ------------------------------------------------------------
# 🧠 Systembibliothek laden (für DebugMode)
# ------------------------------------------------------------
. "$PSScriptRoot\Lib_Systeminfo.ps1"

# ------------------------------------------------------------
# 🪲 Write-DebugLog
# Zweck: Gibt Debug-Informationen in der Konsole aus
# ------------------------------------------------------------
function Write-DebugLog {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Prefix = ""
    )

    try {
        if (-not (Get-DebugMode)) { return }

        $time = (Get-Date).ToString("HH:mm:ss")
        $prefixText = if ($Prefix) { "[$Prefix] " } else { "" }

        Write-Host "[$time] 🪲 ${prefixText}$Message" -ForegroundColor DarkYellow
    }
    catch {
        Write-Host "⚠️  Fehler in Write-DebugLog: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 🪲 Write-DebugFile
# Zweck: Schreibt Debug-Informationen in eine Logdatei (eine pro Sitzung)
# ------------------------------------------------------------
function Write-DebugFile {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Prefix = ""
    )

    try {
        if (-not (Get-DebugMode)) { return }

        $rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $logDir = Join-Path $rootPath "04_Logs"

        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir | Out-Null
        }

        # 🧩 Datei einmal pro Sitzung erstellen
        if (-not $script:DebugLogFile) {
            $timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
            $script:DebugLogFile = Join-Path $logDir ("Debug_" + $timestamp + ".log")

            # Eintrag nur einmal am Anfang
            Add-Content -Path $script:DebugLogFile -Value "=== DEBUG-SITZUNG START | $timestamp ==="
        }

        $time = (Get-Date).ToString("HH:mm:ss")
        $prefixText = if ($Prefix) { "[$Prefix] " } else { "" }

        $entry = "[$time] 🪲 ${prefixText}$Message"
        Add-Content -Path $script:DebugLogFile -Value $entry
    }
    catch {
        Write-Host "⚠️  Fehler in Write-DebugFile: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# 🧩 Write-Debug
# Zweck: Kombiniert Konsolen- und Dateiausgabe
# ------------------------------------------------------------
function Write-Debug {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Prefix = ""
    )

    Write-DebugLog -Message $Message -Prefix $Prefix
    Write-DebugFile -Message $Message -Prefix $Prefix
}
