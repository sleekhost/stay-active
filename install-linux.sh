#!/bin/bash
#
# install-linux.sh - Linux installer for stay-active
#

set -e

VERSION="1.0.0"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_URL="https://raw.githubusercontent.com/sleekhost/stay-active/main/stay-active"
DEST="$INSTALL_DIR/stay-active"

echo "Installing stay-active v${VERSION} for Linux..."
echo ""

# 1. Install xdotool
echo "[1/4] Installing xdotool..."
if command -v xdotool &>/dev/null; then
    echo "      xdotool already installed"
elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y xdotool
elif command -v dnf &>/dev/null; then
    sudo dnf install -y xdotool
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm xdotool
elif command -v zypper &>/dev/null; then
    sudo zypper install -y xdotool
else
    echo "Could not detect package manager. Install xdotool manually."
    echo "Then re-run this installer."
    exit 1
fi

# 2. Create bin directory
echo "[2/4] Creating $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# 3. Download script
echo "[3/4] Downloading stay-active..."
curl -fsSL "$SCRIPT_URL" -o "$DEST"
chmod +x "$DEST"
echo "      Saved to $DEST"

# 4. Add to PATH
echo "[4/4] Updating PATH..."
ADDED=0
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q '\.local/bin' "$rc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        echo "      Added to $rc"
        ADDED=1
    fi
done
if [ $ADDED -eq 0 ]; then
    echo "      Already in PATH"
fi

echo ""
echo "Done! stay-active is installed."
echo ""
echo "Restart your terminal, then:"
echo "  stay-active start    # Start keeping you active"
echo "  stay-active stop"
echo "  stay-active status"
echo "  stay-active log"
