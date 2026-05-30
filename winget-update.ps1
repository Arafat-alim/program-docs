<#
.SYNOPSIS
    Auto-update all winget packages EXCEPT those in $IgnoreList.
.DESCRIPTION
    Run anytime to upgrade everything. Edit $IgnoreList to skip specific apps.
    Run as Administrator for system-wide installs.
.USAGE
    powershell -ExecutionPolicy Bypass -File "D:\work\markdown-converted-files\winget-update.ps1"
#>

# ─── IGNORE LIST: these apps will NEVER be upgraded ──────────────────────────
$IgnoreList = @(
    "RevoUninstaller.RevoUninstallerPro",   # Revo Uninstaller Pro
    "Wondershare.PDFelement.12",            # Wondershare PDFelement
    "ByteDance.CapCut",                     # CapCut
    "Dyad.Dyad"                             # dyad
)
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n[winget-update] Fetching upgrade list..." -ForegroundColor Cyan
$rawLines = winget upgrade --accept-source-agreements 2>&1

# Find header line to determine column positions
$headerLine = $rawLines | Where-Object { $_ -match '\bId\b.*\bVersion\b.*\bAvailable\b' } | Select-Object -First 1

if (-not $headerLine) {
    Write-Host "[winget-update] Nothing to upgrade or winget unavailable." -ForegroundColor Yellow
    exit 0
}

$idCol  = $headerLine.IndexOf('Id')
$verCol = $headerLine.IndexOf('Version')

# Parse lines after the "----" separator
$inData     = $false
$upgradeIds = @()

foreach ($line in $rawLines) {
    if ($line -match '^[-\s]{10,}$') { $inData = $true; continue }
    if (-not $inData) { continue }
    if ($line.Trim() -eq '' -or $line -match '^\d+ upgrades? available') { continue }

    if ($line.Length -gt ($idCol + 1)) {
        $idLen = if ($verCol -gt $idCol) { $verCol - $idCol } else { 50 }
        $id = $line.Substring($idCol, [Math]::Min($idLen, $line.Length - $idCol)).Trim()
        if ($id -and $id -notmatch '^-') {
            $upgradeIds += $id
        }
    }
}

# Remove ignored + dedup
$upgradeIds = $upgradeIds | Where-Object { $_ -notin $IgnoreList } | Select-Object -Unique

Write-Host "[winget-update] $($upgradeIds.Count) packages to upgrade" -ForegroundColor Green
Write-Host "[winget-update] Ignoring: $($IgnoreList -join ', ')`n" -ForegroundColor DarkYellow

if ($upgradeIds.Count -eq 0) {
    Write-Host "All packages up to date." -ForegroundColor Green
    exit 0
}

$success = 0
$failed  = @()

foreach ($id in $upgradeIds) {
    Write-Host "──── Upgrading: $id" -ForegroundColor Cyan
    winget upgrade --id $id --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        $success++
        Write-Host "     OK`n" -ForegroundColor Green
    } else {
        $failed += $id
        Write-Host "     FAILED (exit $LASTEXITCODE)`n" -ForegroundColor Red
    }
}

Write-Host "`n══════════════════════════════════════════" -ForegroundColor White
Write-Host " DONE: $success succeeded  |  $($failed.Count) failed" -ForegroundColor $(if ($failed.Count -eq 0) { 'Green' } else { 'Yellow' })
if ($failed.Count -gt 0) {
    Write-Host " Failed IDs:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
}
Write-Host "══════════════════════════════════════════`n" -ForegroundColor White
