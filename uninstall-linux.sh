#!/bin/bash
#
# uninstall-linux.sh - Linux uninstaller for stay-active
#

INSTALL_DIR="$HOME/.local/bin"
SCRIPT="$INSTALL_DIR/stay-active"

echo "Uninstalling stay-active..."
echo ""

# 1. Stop daemon if running
echo "[1/3] Stopping daemon (if running)..."
if [ -x "$SCRIPT" ]; then
    "$SCRIPT" stop 2>/dev/null || true
else
    echo "      Script not found, skipping."
fi

# 2. Remove script
echo "[2/3] Removing script..."
if [ -f "$SCRIPT" ]; then
    rm -f "$SCRIPT"
    echo "      Removed $SCRIPT"
else
    echo "      Not found: $SCRIPT"
fi

# 3. Remove data files
echo "[3/3] Removing data files..."
for f in "$HOME/.local/.stay_active_on" "$HOME/.local/.stay_active_pid" "$HOME/.local/.stay_active_log"; do
    [ -f "$f" ] && rm -f "$f" && echo "      Removed $f"
done

echo ""
echo "stay-active has been uninstalled."
echo ""
echo "Note: xdotool was not removed. To uninstall it:"
echo "  Ubuntu/Debian:  sudo apt remove xdotool"
echo "  Fedora/RHEL:    sudo dnf remove xdotool"
echo "  Arch Linux:     sudo pacman -R xdotool"
