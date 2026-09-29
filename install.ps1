$ErrorActionPreference = "Stop"
$repo = "KhornVictor/mkfolders"
$version = "v1.0.0"

$installDir = "C:\Tool\mkfolders"
$exePath = "$installDir\mkfolders.exe"
$downloadUrl = "https://github.com/$repo/releases/download/$version/mkfolders.exe"

Write-Host ""
Write-Host "Installing mkfolders..." -ForegroundColor Cyan
Write-Host ""
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Downloading mkfolders $version..." -ForegroundColor Yellow

Invoke-WebRequest `    -Uri $downloadUrl`
-OutFile $exePath

Write-Host "Installed: $exePath" -ForegroundColor Green
]
$profileDir = Split-Path -Parent $PROFILE

if (-not (Test-Path $profileDir)) {
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

if (-not (Test-Path $PROFILE)) {
New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$function = @'

function mkfolders {
& "C:\Tool\mkfolders\mkfolders.exe" @args
}

'@

$profileContent = Get-Content -Path $PROFILE -Raw

if ($profileContent -notmatch 'function mkfolders\s*{') {
Add-Content -Path $PROFILE -Value $function

```
Write-Host "Added mkfolders to PowerShell profile." -ForegroundColor Green
```

}
else {
Write-Host "mkfolders is already configured in PowerShell profile." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Restart PowerShell or run:" -ForegroundColor Cyan
Write-Host "  . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "Then use:" -ForegroundColor Cyan
Write-Host "  mkfolders src components services" -ForegroundColor White
Write-Host ""
