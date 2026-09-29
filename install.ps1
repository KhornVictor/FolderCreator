# ==============================================================================
# FolderCreator Automated Installer for Windows & PowerShell
# Supports:
#   1. Remote one-liner:
#      irm https://raw.githubusercontent.com/KhornVictor/FolderCreator/main/install.ps1 | iex
#   2. Local execution:
#      .\install.ps1
# ==============================================================================

[CmdletBinding()]
param(
    [string]$InstallPath = "",
    [switch]$SkipBuild,
    [switch]$SkipProfile
)

Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              📁 FOLDERCREATOR INSTALLER                     ║" -ForegroundColor Cyan
Write-Host "║      Builds binary and configures PowerShell profile        ║" -ForegroundColor White
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Determine installation directory
if ($InstallPath -and $InstallPath.Trim() -ne "") {
    $installDir = $InstallPath
} elseif ($PSScriptRoot) {
    # Running locally from repo clone
    $installDir = $PSScriptRoot
} else {
    # Running remotely via 'irm ... | iex'
    # Default to C:\Tool\FolderCreator or $HOME\.foldercreator
    $preferredPath = "C:\Tool\FolderCreator"
    try {
        if (-not (Test-Path "C:\Tool")) {
            New-Item -ItemType Directory -Path "C:\Tool" -Force -ErrorAction Stop | Out-Null
        }
        $installDir = $preferredPath
    } catch {
        $installDir = Join-Path $HOME "FolderCreator"
    }
}

Write-Host "📂 Target directory: $installDir" -ForegroundColor Yellow

# If directory does not exist or has no Cargo.toml, clone or download repo
$cargoToml = Join-Path $installDir "Cargo.toml"
if (-not (Test-Path $cargoToml)) {
    Write-Host "`n[1/4] Downloading FolderCreator source code..." -ForegroundColor Cyan

    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        Write-Host "  ✔ Cloning via Git into '$installDir'..." -ForegroundColor Green
        & git clone https://github.com/KhornVictor/FolderCreator.git $installDir
    } else {
        Write-Host "  ℹ Git not found; downloading archive from GitHub..." -ForegroundColor Yellow
        $zipUrl = "https://github.com/KhornVictor/FolderCreator/archive/refs/heads/main.zip"
        $zipFile = Join-Path $env:TEMP "FolderCreator-main.zip"
        $extractDir = Join-Path $env:TEMP "FolderCreator-extract"

        Invoke-RestMethod -Uri $zipUrl -OutFile $zipFile
        if (Test-Path $extractDir) {
            Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
        Copy-Item "$extractDir\FolderCreator-main\*" $installDir -Recurse -Force
        Remove-Item $zipFile, $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✔ Extracted source to '$installDir'" -ForegroundColor Green
    }
} else {
    Write-Host "  ✔ Found existing source code in '$installDir'" -ForegroundColor Green
}

$releaseDir = Join-Path $installDir "target\release"
$targetExe = Join-Path $releaseDir "FolderCreator.exe"
$profileScript = Join-Path $installDir "profile.ps1"

# Check Cargo & Build
if (-not $SkipBuild) {
    Write-Host "`n[2/4] Checking prerequisites..." -ForegroundColor Cyan
    $cargoCmd = Get-Command cargo -ErrorAction SilentlyContinue
    if (-not $cargoCmd) {
        Write-Warning "Rust and Cargo were not found on your PATH."
        Write-Host "Please install Rust from https://rustup.rs and rerun this installer." -ForegroundColor Yellow
        return
    }
    Write-Host "  ✔ Found Cargo at $($cargoCmd.Source)" -ForegroundColor Green

    Write-Host "`n[3/4] Building release binary..." -ForegroundColor Cyan
    Push-Location $installDir
    try {
        & cargo build --release
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Cargo build failed with exit code $LASTEXITCODE."
            return
        }
    } finally {
        Pop-Location
    }

    if (-not (Test-Path $targetExe)) {
        Write-Error "Executable not found at '$targetExe'."
        return
    }
    Write-Host "  ✔ Binary built at '$targetExe'" -ForegroundColor Green
} else {
    Write-Host "`n[2/4] Skipping build step as requested." -ForegroundColor Yellow
}

# Configure PowerShell Profile
if (-not $SkipProfile) {
    Write-Host "`n[4/4] Configuring PowerShell profile..." -ForegroundColor Cyan

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
        Write-Host "  ℹ PowerShell profile is already configured." -ForegroundColor Yellow
    } else {
        $block = @"

# --- FolderCreator / mkfolders CLI ---
if (Test-Path "$profileScript") {
    $importLine
}
"@
        Add-Content -Path $PROFILE -Value $block
        Write-Host "  ✔ Added FolderCreator loader to $PROFILE" -ForegroundColor Green
    }

    # Load immediately into current session
    if (Test-Path $profileScript) {
        . $profileScript
        Write-Host "  ✔ Loaded mkfolders function into active session" -ForegroundColor Green
    }
}

# Add to User PATH
try {
    $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    if ($userPath -split ';' -notcontains $releaseDir) {
        $newPath = if ($userPath) { "$userPath;$releaseDir" } else { $releaseDir }
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
        $env:Path += ";$releaseDir"
        Write-Host "  ✔ Added '$releaseDir' to User PATH" -ForegroundColor Green
    }
} catch {
    Write-Warning "Could not update User PATH: $_"
}

Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                 🎉 INSTALLATION SUCCESSFUL!                 ║" -ForegroundColor Green
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "FolderCreator is now ready to use!" -ForegroundColor White
Write-Host ""
Write-Host "Try it right now:" -ForegroundColor White
Write-Host "  mkfolders                 # Modern interactive mode" -ForegroundColor Cyan
Write-Host "  mkfolders src docs tests  # Direct command-line creation" -ForegroundColor Cyan
Write-Host "  foldercreator             # Alias for mkfolders" -ForegroundColor Cyan
Write-Host ""
Write-Host "In any new terminal window, mkfolders is loaded automatically." -ForegroundColor DarkGray
Write-Host ""
