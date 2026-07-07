# setup.ps1 — One-shot Scoop environment sync
# Run this on a new machine to replicate the full app suite.
#
# Usage:
#   scoop bucket add mybucket https://github.com/nwsytyc/scoop-bucket.git
#   scoop install mybucket/setup-helper  # or just run this directly:
#   powershell -File setup.ps1

param(
    [string]$PackagesFile = "$PSScriptRoot/packages.json",
    [switch]$SkipBuckets  = $false,
    [switch]$SkipApps     = $false,
    [switch]$DryRun       = $false
)

$ErrorActionPreference = "Stop"

# ── Load packages.json ──
if (-not (Test-Path $PackagesFile)) {
    Write-Error "packages.json not found at $PackagesFile"
    exit 1
}

$pkg = Get-Content $PackagesFile -Raw | ConvertFrom-Json

# ── 1. Add buckets ──
if (-not $SkipBuckets) {
    Write-Host "`n[1/3] Adding Scoop buckets..." -ForegroundColor Cyan

    # Ensure Scoop is installed
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop first..." -ForegroundColor Yellow
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    foreach ($bucket in $pkg.buckets.PSObject.Properties) {
        $name = $bucket.Name
        $url  = $bucket.Value
        Write-Host "  Adding bucket: $name ($url)" -ForegroundColor Gray

        if ($DryRun) { continue }

        # Check if already added
        $existing = scoop bucket list 2>$null | Select-String -Pattern $name
        if ($existing) {
            Write-Host "    Already exists, skipping." -ForegroundColor DarkGray
        } else {
            scoop bucket add $name $url
        }
    }
}

# ── 2. Install apps ──
if (-not $SkipApps) {
    Write-Host "`n[2/3] Installing apps..." -ForegroundColor Cyan
    $total = 0
    $installed = 0
    $skipped = 0

    foreach ($bucketEntry in $pkg.apps.PSObject.Properties) {
        $bucket = $bucketEntry.Name
        $apps   = $bucketEntry.Value

        foreach ($app in $apps) {
            $total++
            # Check if already installed
            $already = scoop list $app 2>$null | Select-String -Pattern $app
            if ($already) {
                Write-Host "  [skip] $app (already installed)" -ForegroundColor DarkGray
                $skipped++
                continue
            }

            if ($DryRun) {
                Write-Host "  [dry]  scoop install $bucket/$app" -ForegroundColor Yellow
                continue
            }

            Write-Host "  Installing $bucket/$app..." -ForegroundColor White
            scoop install "$bucket/$app"
            $installed++
        }
    }

    Write-Host "`n  Total: $total | Installed: $installed | Skipped: $skipped" -ForegroundColor Green
}

# ── 3. Hold pinned versions ──
if ($pkg.held -and -not $DryRun) {
    Write-Host "`n[3/3] Setting held packages..." -ForegroundColor Cyan
    foreach ($hold in $pkg.held.PSObject.Properties) {
        $app = $hold.Name
        $ver = $hold.Value
        Write-Host "  Holding $app at $ver" -ForegroundColor Gray
        scoop hold $app
    }
}

Write-Host "`nDone! Run 'scoop update --all' to get the latest versions.`n" -ForegroundColor Green
