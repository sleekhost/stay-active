<p align="center">
  <h1 align="center">stay-active</h1>
  <p align="center">
    <strong>Keep Microsoft Teams (and other apps) showing you as "Active" on macOS and Windows</strong>
  </p>
  <p align="center">
    <a href="https://www.apple.com/macos"><img src="https://img.shields.io/badge/macOS-10.13+-blue.svg?style=for-the-badge&logo=apple" alt="macOS"></a>
    <a href="https://www.microsoft.com/windows"><img src="https://img.shields.io/badge/Windows-10%2F11-0078D6.svg?style=for-the-badge&logo=windows" alt="Windows"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"></a>
    <a href="https://www.gnu.org/software/bash/"><img src="https://img.shields.io/badge/Shell-Bash-4EAA25.svg?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash"></a>
    <a href="https://learn.microsoft.com/powershell/"><img src="https://img.shields.io/badge/PowerShell-5.1+-5391FE.svg?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell"></a>
  </p>
</p>

<p align="center">
  <img src="assets/demo.gif" alt="stay-active demo" width="600">
</p>

<p align="center">
  <em>No more getting marked as "Away" during bathroom breaks, coffee runs, or deep work sessions.</em>
</p>

---

## The Problem

Microsoft Teams marks you as **"Away" after just 5 minutes** of inactivity. There's no built-in setting to change this.

This creates problems:
- Makes you look unproductive during legitimate breaks
- Triggers unnecessary check-ins from managers
- Creates false impressions about your availability
- Penalizes deep work (reading docs, thinking, planning)

## The Solution

`stay-active` simulates natural human activity at random intervals:

| Feature | Description |
|---------|-------------|
| **Mouse Movement** | Tiny, random movements (1-5 pixels) |
| **Keyboard Activity** | Shift key press (invisible, non-disruptive) |
| **Human-like Patterns** | Random intervals (30-60 sec), not predictable |
| **Lightweight** | Pure shell script, ~6KB, no heavy dependencies |
| **Logging** | Built-in activity log to verify it's working |

---

## Quick Install

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/sleekhost/stay-active/main/install.sh | bash
```

The installer handles everything: Homebrew, cliclick, PATH setup.

### Windows

```powershell
irm https://raw.githubusercontent.com/sleekhost/stay-active/main/install.ps1 | iex
```

No external dependencies — uses the Win32 API built into Windows. If script execution is blocked, run this first:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

<details>
<summary><strong>Windows Manual Installation</strong></summary>

```powershell
# 1. Create bin directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin" -Force

# 2. Download script
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/sleekhost/stay-active/main/stay-active.ps1" `
  -OutFile "$env:USERPROFILE\.local\bin\stay-active.ps1"

# 3. Add to PATH (run once; restart terminal after)
$p = [Environment]::GetEnvironmentVariable("PATH","User")
[Environment]::SetEnvironmentVariable("PATH","$p;$env:USERPROFILE\.local\bin","User")
```

</details>

<details>
<summary><strong>macOS Manual Installation</strong></summary>

### 1. Install cliclick

```bash
brew install cliclick
```

### 2. Download stay-active

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/sleekhost/stay-active/main/stay-active -o ~/.local/bin/stay-active
chmod +x ~/.local/bin/stay-active
```

### 3. Add to PATH

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 4. Grant Accessibility Permissions

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click **+** and add **Terminal** (or your terminal app)
3. Also add `/opt/homebrew/bin/cliclick`

</details>

---

## Usage

### macOS

```bash
stay-active start     # Start keeping you active
stay-active stop      # Stop the daemon
stay-active toggle    # Toggle on/off
stay-active status    # Check if running
stay-active log       # View activity log
stay-active --help    # Show all commands
```

### Windows

```powershell
.\stay-active.ps1 start     # Start keeping you active
.\stay-active.ps1 stop      # Stop the daemon
.\stay-active.ps1 toggle    # Toggle on/off
.\stay-active.ps1 status    # Check if running
.\stay-active.ps1 log       # View activity log
.\stay-active.ps1 --help    # Show all commands
```

### Example

```
$ stay-active start       (or .\stay-active.ps1 start on Windows)
Started (PID: 12345)

$ stay-active status
Running (PID: 12345)

$ stay-active log
[2025-01-15 09:30:45] Daemon started (v1.0.0)
[2025-01-15 09:30:45] Activity: mouse (500,400)->(503,398) + shift key
[2025-01-15 09:30:45] Sleeping 42s
...
```

---

## How It Works

```
Every 30-60 seconds (randomized):
  1. Move mouse 1-5 pixels in random direction
  2. Press + release Shift key
  3. 60% chance: move mouse back to original position
  4. 15% of cycles: use shorter 15-30 sec intervals
```

This mimics natural human behavior — no predictable patterns that could be flagged.

---

## Requirements

### macOS

| Requirement | Details |
|-------------|---------|
| **macOS** | 10.13 (High Sierra) or newer |
| **Homebrew** | Package manager ([brew.sh](https://brew.sh)) |
| **cliclick** | Mouse/keyboard automation (auto-installed) |
| **Permissions** | Accessibility access for Terminal |

### Windows

| Requirement | Details |
|-------------|---------|
| **Windows** | 10 or 11 |
| **PowerShell** | 5.1+ (pre-installed on Windows 10/11) |
| **Dependencies** | None — uses Win32 API built into Windows |

---

## Troubleshooting

<details>
<summary><strong>"cliclick not found"</strong></summary>

```bash
brew install cliclick
```
</details>

<details>
<summary><strong>"Accessibility privileges not enabled"</strong></summary>

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Add your terminal app (Terminal, iTerm, etc.)
3. Add `/opt/homebrew/bin/cliclick`
</details>

<details>
<summary><strong>Teams still shows "Away"</strong></summary>

1. Check the log: `stay-active log`
2. Verify it's running: `stay-active status`
3. Restart: `stay-active stop && stay-active start`
4. Make sure Accessibility permissions are granted
</details>

---

## Uninstall

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/sleekhost/stay-active/main/uninstall.sh | bash
```

<details>
<summary><strong>macOS Manual uninstall</strong></summary>

```bash
stay-active stop
rm ~/.local/bin/stay-active
rm ~/.local/.stay_active_*
brew uninstall cliclick  # optional
```
</details>

### Windows

```powershell
irm https://raw.githubusercontent.com/sleekhost/stay-active/main/uninstall.ps1 | iex
```

<details>
<summary><strong>Windows Manual uninstall</strong></summary>

```powershell
.\stay-active.ps1 stop
Remove-Item "$env:USERPROFILE\.local\bin\stay-active.ps1" -Force
Remove-Item "$env:LOCALAPPDATA\stay-active" -Recurse -Force
```
</details>

---

## Privacy & Security

- **100% Local** — No data sent anywhere, no analytics
- **Offline** — Works without internet
- **Open Source** — Review every line of code
- **Minimal** — Only needs Accessibility permission

---

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

**Ideas:**
- [ ] Linux support (xdotool)
- [x] Windows support (PowerShell)
- [ ] Configurable intervals
- [ ] Schedule mode (work hours only)
- [ ] Native menu bar app

---

## License

[MIT](LICENSE) — Do whatever you want with it.

---

<p align="center">
  <strong>Made by <a href="https://github.com/sleekhost">Sleekhost</a></strong>
</p>

<p align="center">
  <em>If this helped you, consider giving it a ⭐</em>
</p>
