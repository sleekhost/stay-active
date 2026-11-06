# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-06

### Added
- Windows support via `stay-active.ps1` PowerShell script
- `install.ps1` — one-command Windows installer (no admin required)
- `uninstall.ps1` — Windows uninstaller
- No external dependencies on Windows — uses Win32 API directly via P/Invoke
- Same commands as macOS version: start, stop, toggle, status, log

### Technical Details
- PowerShell 5.1+ implementation
- Uses `user32.dll` (`GetCursorPos`, `SetCursorPos`, `keybd_event`) for input simulation
- Daemon runs as a hidden background PowerShell process
- State files stored in `%LOCALAPPDATA%\stay-active\`

---

## [1.0.0] - 2025-12-09

### Added
- Initial release
- Mouse movement simulation (1-5 pixels, random direction)
- Keyboard activity simulation (Shift key press)
- Random intervals (30-60 seconds) with 15% shorter bursts
- Human-like behavior (60% chance to return to original position)
- Commands: start, stop, toggle, status, log
- Colored terminal output
- Activity logging
- Help and version flags
- One-command installer script
- Uninstaller script

### Technical Details
- Pure Bash implementation
- Uses cliclick for mouse/keyboard automation
- Runs as background daemon
- Control via file-based flags
