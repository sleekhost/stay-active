#Requires -Version 5.1
<#
.SYNOPSIS
    Installer for stay-active on Windows
.DESCRIPTION
    Downloads stay-active.ps1 to ~/.local/bin and adds it to your user PATH.
#>

$VERSION = "1.0.0"
$INSTALL_DIR = "$env:USERPROFILE\.local\bin"
$PS1_URL = "https://raw.githubusercontent.com/sleekhost/stay-active/main/stay-active.ps1"
$BAT_URL = "https://raw.githubusercontent.com/sleekhost/stay-active/main/stay-active.bat"
$PS1_DEST = "$INSTALL_DIR\stay-active.ps1"
$BAT_DEST = "$INSTALL_DIR\stay-active.bat"

Write-Host "Installing stay-active v$VERSION for Windows..."
Write-Host ""

# 1. Create install directory
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Write-Host "[1/4] Created $INSTALL_DIR"

# 2. Download PowerShell script
Write-Host "[2/4] Downloading stay-active.ps1..."
try {
    Invoke-WebRequest -Uri $PS1_URL -OutFile $PS1_DEST -UseBasicParsing -ErrorAction Stop
    Write-Host "       Saved to $PS1_DEST"
}
catch {
    Write-Host "Error: Failed to download stay-active.ps1" -ForegroundColor Red
    Write-Host "       $_"
    exit 1
}

# 3. Download cmd wrapper
Write-Host "[3/4] Downloading stay-active.bat (cmd.exe support)..."
try {
    Invoke-WebRequest -Uri $BAT_URL -OutFile $BAT_DEST -UseBasicParsing -ErrorAction Stop
    Write-Host "       Saved to $BAT_DEST"
}
catch {
    Write-Host "Error: Failed to download stay-active.bat" -ForegroundColor Red
    Write-Host "       $_"
    exit 1
}

# 4. Add to user PATH (persistent, no admin required)
Write-Host "[4/4] Updating PATH..."
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$INSTALL_DIR", "User")
    Write-Host "       Added $INSTALL_DIR to user PATH"
    Write-Host "       Restart your terminal for PATH changes to take effect."
}
else {
    Write-Host "       $INSTALL_DIR already in PATH"
}

Write-Host ""
Write-Host "Done! stay-active is installed." -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: To allow PowerShell scripts, run once:"
Write-Host "  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
Write-Host ""
Write-Host "Usage after restarting your terminal:"
Write-Host "  stay-active start    # works in PowerShell AND cmd.exe"
Write-Host "  stay-active stop"
Write-Host "  stay-active status"
Write-Host "  stay-active log"
