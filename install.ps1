# ==============================================================================
# FolderCreator Automated Installer for Windows & PowerShell
# Usage: .\install.ps1
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'

Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              📁 FOLDERCREATOR INSTALLER                     ║" -ForegroundColor Cyan
Write-Host "║      Builds binary and configures PowerShell profile        ║" -ForegroundColor White
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$rootDir = $PSScriptRoot
$releaseDir = Join-Path $rootDir "target\release"
$targetExe = Join-Path $releaseDir "FolderCreator.exe"
$profileScript = Join-Path $rootDir "profile.ps1"

# 1. Check Cargo
if (-not $SkipBuild) {
    Write-Host "[1/3] Checking prerequisites..." -ForegroundColor Cyan
    $cargoCmd = Get-Command cargo -ErrorAction SilentlyContinue
    if (-not $cargoCmd) {
        Write-Error "Rust and Cargo were not found on your PATH. Please install Rust from https://rustup.rs first."
        exit 1
    }
    Write-Host "  ✔ Found $($cargoCmd.Source)" -ForegroundColor Green

    # 2. Build Release Binary
    Write-Host "`n[2/3] Building release binary..." -ForegroundColor Cyan
    Push-Location $rootDir
    try {
        & cargo build --release
        if ($LASTEXITCODE -ne 0) {
            throw "Cargo build failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }

    if (-not (Test-Path $targetExe)) {
        Write-Error "Build completed, but executable was not found at '$targetExe'."
        exit 1
    }
    Write-Host "  ✔ Binary built successfully at '$targetExe'" -ForegroundColor Green
} else {
    Write-Host "[1/2] Skipping build step as requested." -ForegroundColor Yellow
}

# 3. Configure PowerShell Profile
if (-not $SkipProfile) {
    Write-Host "`n[3/3] Configuring PowerShell profile..." -ForegroundColor Cyan

    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "  ✔ Created profile directory: $profileDir" -ForegroundColor Green
    }

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "  ✔ Created profile file: $PROFILE" -ForegroundColor Green
    }

    $existingContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    $importLine = ". `"$profileScript`""

    if ($existingContent -and ($existingContent -match "FolderCreator|profile\.ps1")) {
        Write-Host "  ℹ PowerShell profile is already configured with FolderCreator." -ForegroundColor Yellow
    } else {
        $block = "`n# --- FolderCreator / mkfolders CLI ---`nif (Test-Path `"$profileScript`") {`n    $importLine`n}`n"
        Add-Content -Path $PROFILE -Value $block
        Write-Host "  ✔ Added FolderCreator loader to $PROFILE" -ForegroundColor Green
    }
}

# 4. Optional: Add to User PATH
try {
    $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $normalizedRelease = (Resolve-Path $releaseDir -ErrorAction SilentlyContinue).Path
    if ($normalizedRelease -and ($userPath -split ';' -notcontains $normalizedRelease)) {
        $newPath = if ($userPath) { "$userPath;$normalizedRelease" } else { $normalizedRelease }
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
        $env:Path += ";$normalizedRelease"
        Write-Host "  ✔ Added '$normalizedRelease' to User PATH environment variable." -ForegroundColor Green
    }
} catch {
    Write-Warning "Could not update User PATH: $_"
}

Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                 🎉 INSTALLATION SUCCESSFUL!                 ║" -ForegroundColor Green
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "To use the tool right now in this PowerShell window, run:" -ForegroundColor White
Write-Host "  . `$PROFILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "Available commands:" -ForegroundColor White
Write-Host "  mkfolders                 # Launch interactive UI mode" -ForegroundColor Cyan
Write-Host "  mkfolders src docs tests  # Direct command-line creation" -ForegroundColor Cyan
Write-Host "  foldercreator             # Alias for mkfolders" -ForegroundColor Cyan
Write-Host ""
