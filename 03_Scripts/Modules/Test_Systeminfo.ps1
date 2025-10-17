# ============================================================
# Test: Lib_Systeminfo.ps1
# Zweck: Prüft, ob System automatisch erkannt und JSON erstellt wird
# ============================================================

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     🧩 TEST – LIB_SYSTEMINFO.PS1             " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan

# Library einbinden
. "$PSScriptRoot\..\Libs\Lib_Systeminfo.ps1"

# Funktion ausführen
$sysInfo = Get-SystemInfo

# Ergebnis prüfen
Write-Host "`n✅ Aktuelle Systeminformationen:" -ForegroundColor Green
Write-Host "👤 Benutzer:  $($sysInfo.Benutzername)"
Write-Host "🖥️  Computer: $($sysInfo.Computername)"
Write-Host "💽 System:    $($sysInfo.System)"
Write-Host "📂 RootPath:  $($sysInfo.Systempfade.RootPath)"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "Testlauf abgeschlossen." -ForegroundColor Green
Write-Host "=============================================`n" -ForegroundColor Cyan
