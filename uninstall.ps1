#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstaller for stay-active on Windows
.DESCRIPTION
    Stops the daemon, removes the script from ~/.local/bin, and cleans up data files.
#>

$INSTALL_DIR = "$env:USERPROFILE\.local\bin"
$PS1 = "$INSTALL_DIR\stay-active.ps1"
$BAT = "$INSTALL_DIR\stay-active.bat"
$DATA_DIR = "$env:LOCALAPPDATA\stay-active"

Write-Host "Uninstalling stay-active..."
Write-Host ""

# 1. Stop daemon if running
if (Test-Path $PS1) {
    Write-Host "[1/4] Stopping daemon (if running)..."
    & powershell.exe -ExecutionPolicy Bypass -File $PS1 stop
}
else {
    Write-Host "[1/4] Script not found, skipping daemon stop."
}

# 2. Remove PowerShell script
Write-Host "[2/4] Removing stay-active.ps1..."
if (Test-Path $PS1) {
    Remove-Item $PS1 -Force
    Write-Host "       Removed $PS1"
}
else {
    Write-Host "       Not found: $PS1"
}

# 3. Remove cmd.exe wrapper
Write-Host "[3/4] Removing stay-active.bat..."
if (Test-Path $BAT) {
    Remove-Item $BAT -Force
    Write-Host "       Removed $BAT"
}
else {
    Write-Host "       Not found: $BAT"
}

# 4. Remove data directory (logs, control files, pid)
Write-Host "[4/4] Removing data files..."
if (Test-Path $DATA_DIR) {
    Remove-Item $DATA_DIR -Recurse -Force
    Write-Host "       Removed $DATA_DIR"
}
else {
    Write-Host "       Not found: $DATA_DIR"
}

# Remove from user PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -like "*$INSTALL_DIR*") {
    $newPath = ($currentPath -split ";" | Where-Object { $_ -ne $INSTALL_DIR }) -join ";"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "       Removed $INSTALL_DIR from user PATH"
}

Write-Host ""
Write-Host "stay-active has been uninstalled." -ForegroundColor Green
