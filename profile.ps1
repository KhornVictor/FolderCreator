$script:FolderCreatorExe = "$PSScriptRoot\target\release\FolderCreator.exe"
if (-not (Test-Path $script:FolderCreatorExe)) {
    $script:FolderCreatorExe = "C:\Tool\FolderCreator\target\release\FolderCreator.exe"
}
if (-not (Test-Path $script:FolderCreatorExe)) {
    $cmd = Get-Command FolderCreator.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        $script:FolderCreatorExe = $cmd.Source
    }
}

function mkfolders {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$FolderArgs
    )

    if (Test-Path $script:FolderCreatorExe) {
        & $script:FolderCreatorExe @FolderArgs
    } else {
        Write-Warning "FolderCreator binary not found at '$script:FolderCreatorExe'."
        Write-Host "Run 'cargo build --release' in 'C:\Tool\FolderCreator' or execute '.\install.ps1'" -ForegroundColor Yellow
    }
}

Set-Alias -Name foldercreator -Value mkfolders -ErrorAction SilentlyContinue