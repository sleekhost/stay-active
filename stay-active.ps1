#Requires -Version 5.1
<#
.SYNOPSIS
    stay-active - Keep Microsoft Teams (and other apps) showing you as "Active" on Windows
.DESCRIPTION
    Simulates natural mouse movement and keyboard activity at random intervals
    to prevent apps from marking you as "Away".
.EXAMPLE
    .\stay-active.ps1 start
    .\stay-active.ps1 stop
    .\stay-active.ps1 status
#>

# Use $args directly so "--version" and "-h" aren't intercepted by PowerShell's param binder
$Command = if ($args.Count -gt 0) { [string]$args[0] } else { "" }

$VERSION = "1.0.0"
$DATA_DIR = "$env:LOCALAPPDATA\stay-active"
$CONTROL_FILE = "$DATA_DIR\.stay_active_on"
$PID_FILE = "$DATA_DIR\.stay_active_pid"
$LOG_FILE = "$DATA_DIR\.stay_active_log"

New-Item -ItemType Directory -Path $DATA_DIR -Force | Out-Null

# Load Win32 API for mouse and keyboard simulation (guard against re-definition)
if (-not ([System.Management.Automation.PSTypeName]'WinInput').Type) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinInput {
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

    public const byte VK_SHIFT = 0x10;
    public const uint KEYEVENTF_KEYUP = 0x0002;

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int X;
        public int Y;
    }
}
"@
}

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$ts] $Message" | Add-Content -Path $LOG_FILE -Encoding UTF8
}

function Get-RandomInterval {
    return (Get-Random -Minimum 30 -Maximum 61)
}

function Get-RandomOffset {
    return (Get-Random -Minimum -5 -Maximum 6)
}

function Invoke-SimulateActivity {
    Write-Log "Daemon started (v$VERSION)"

    while (Test-Path $CONTROL_FILE) {
        $point = New-Object WinInput+POINT
        $ok = [WinInput]::GetCursorPos([ref]$point)

        if ($ok) {
            $origX = $point.X
            $origY = $point.Y

            $newX = $origX + (Get-RandomOffset)
            $newY = $origY + (Get-RandomOffset)
            if ($newX -lt 10) { $newX = 10 }
            if ($newY -lt 10) { $newY = 10 }

            [WinInput]::SetCursorPos($newX, $newY) | Out-Null

            Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 400)

            # Press and release Shift (registers activity without disrupting user)
            [WinInput]::keybd_event([WinInput]::VK_SHIFT, 0, 0, 0)
            Start-Sleep -Milliseconds 50
            [WinInput]::keybd_event([WinInput]::VK_SHIFT, 0, [WinInput]::KEYEVENTF_KEYUP, 0)

            Write-Log "Activity: mouse ($origX,$origY)->($newX,$newY) + shift key"

            # 60% chance to move back (natural behavior)
            if ((Get-Random -Maximum 10) -lt 6) {
                Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 600)
                [WinInput]::SetCursorPos($origX, $origY) | Out-Null
            }
        }
        else {
            Write-Log "Warning: Could not get mouse position"
        }

        $interval = Get-RandomInterval

        # 15% chance of shorter burst (more active period)
        if ((Get-Random -Maximum 100) -lt 15) {
            $interval = Get-Random -Minimum 15 -Maximum 30
        }

        Write-Log "Sleeping ${interval}s"

        # Sleep in 1-second chunks so stopping is responsive
        for ($i = 0; $i -lt $interval; $i++) {
            if (-not (Test-Path $CONTROL_FILE)) { break }
            Start-Sleep -Seconds 1
        }
    }

    Write-Log "Daemon stopped"
}

function Start-Daemon {
    if (Test-Path $PID_FILE) {
        $existingPid = (Get-Content $PID_FILE -Raw).Trim()
        try {
            Get-Process -Id $existingPid -ErrorAction Stop | Out-Null
            Write-Host "Already running (PID: $existingPid)" -ForegroundColor Yellow
            return
        }
        catch {
            Remove-Item $PID_FILE -Force
        }
    }

    # Rotate log — keep last 100 lines
    if (Test-Path $LOG_FILE) {
        $lines = Get-Content $LOG_FILE
        if ($lines.Count -gt 100) {
            $lines | Select-Object -Last 100 | Set-Content $LOG_FILE -Encoding UTF8
        }
    }

    New-Item -ItemType File -Path $CONTROL_FILE -Force | Out-Null

    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Path }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" _daemon"
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $proc.Id | Set-Content $PID_FILE -Encoding UTF8

    Write-Host "Started (PID: $($proc.Id))" -ForegroundColor Green
}

function Stop-Daemon {
    Remove-Item $CONTROL_FILE -Force -ErrorAction SilentlyContinue

    if (Test-Path $PID_FILE) {
        $existingPid = (Get-Content $PID_FILE -Raw).Trim()
        try {
            Stop-Process -Id $existingPid -Force -ErrorAction Stop
            Write-Log "Stopped by user"
            Write-Host "Stopped" -ForegroundColor Red
        }
        catch {
            Write-Host "Not running" -ForegroundColor Yellow
        }
        Remove-Item $PID_FILE -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "Not running" -ForegroundColor Yellow
    }
}

function Show-Status {
    if ((Test-Path $CONTROL_FILE) -and (Test-Path $PID_FILE)) {
        $existingPid = (Get-Content $PID_FILE -Raw).Trim()
        try {
            Get-Process -Id $existingPid -ErrorAction Stop | Out-Null
            Write-Host "Running (PID: $existingPid)" -ForegroundColor Green
            return 0
        }
        catch {}
    }
    Write-Host "Stopped" -ForegroundColor Red
    return 1
}

function Show-Log {
    if (Test-Path $LOG_FILE) {
        Write-Host "Recent activity:" -ForegroundColor Yellow
        Write-Host ""
        Get-Content $LOG_FILE | Select-Object -Last 20
    }
    else {
        Write-Host "No activity log yet. Start the daemon first."
    }
}

function Show-Help {
    Write-Host @"
stay-active v$VERSION
Keep Microsoft Teams (and other apps) showing you as "Active" on Windows

USAGE:
    .\stay-active.ps1 <command>

COMMANDS:
    start       Start the activity daemon
    stop        Stop the activity daemon
    toggle      Toggle the daemon on/off
    status      Check if daemon is running
    log         View recent activity log

OPTIONS:
    -h, --help      Show this help message
    --version       Show version number

EXAMPLES:
    .\stay-active.ps1 start     # Start keeping you active
    .\stay-active.ps1 stop      # Stop the daemon
    .\stay-active.ps1 toggle    # Quick toggle on/off
    .\stay-active.ps1 log       # See what it's been doing

HOW IT WORKS:
    Simulates natural mouse movement and keyboard activity at random
    intervals (30-60 seconds) to prevent apps from marking you as "Away".
    Uses human-like patterns to avoid detection.

REQUIREMENTS:
    - Windows 10/11
    - PowerShell 5.1+
    - No additional dependencies

DATA LOCATION:
    Logs and state: $DATA_DIR

AUTHOR:
    Sleekhost
    https://github.com/sleekhost/stay-active
"@
}

switch ($Command.ToLower()) {
    ""          {
        Write-Host "stay-active v$VERSION"
        Write-Host ""
        Write-Host "Usage: .\stay-active.ps1 <command>"
        Write-Host ""
        Write-Host "Commands: start, stop, toggle, status, log"
        Write-Host ""
        Write-Host "Run '.\stay-active.ps1 --help' for more information."
    }
    "start"     { Start-Daemon }
    "stop"      { Stop-Daemon }
    "toggle"    { if (Test-Path $CONTROL_FILE) { Stop-Daemon } else { Start-Daemon } }
    "status"    { Show-Status }
    "log"       { Show-Log }
    "_daemon"   { Invoke-SimulateActivity }
    "-h"        { Show-Help }
    "--help"    { Show-Help }
    "help"      { Show-Help }
    "--version" { Write-Host "stay-active v$VERSION" }
    "version"   { Write-Host "stay-active v$VERSION" }
    default     {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Run '.\stay-active.ps1 --help' for usage information."
        exit 1
    }
}
