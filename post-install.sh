#!/bin/bash
set -e

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "ERROR: This script must NOT be run as root" 
   echo "Please run as your regular user account"
   exit 1
fi

echo "=== Arch Linux Post-Installation Setup ==="
echo ""

# Install yay
echo "Installing yay..."
if ! command -v yay &>/dev/null; then
  TEMP=$(mktemp -d)
  cd "$TEMP"
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
  rm -rf "$TEMP"
fi

echo ""

# Install Zsh with Starship prompt
echo "Installing Zsh and Starship..."
sudo pacman -S --needed --noconfirm zsh starship zsh-autosuggestions zsh-syntax-highlighting
chsh -s $(which zsh)

echo ""

# Install DMS
echo "Installing DMS..."
curl -fsSL https://install.danklinux.com -o /tmp/dms-install.sh
sh /tmp/dms-install.sh

yay -S --needed --noconfirm greetd-dms-greeter-git
dms greeter enable
dms greeter sync

echo ""

# Install AUR packages
echo "Installing AUR packages..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=$(cat "$SCRIPT_DIR/aur-packages.txt" | grep -v '^#' | grep -v '^$' | tr '\n' ' ')
yay -S --needed --noconfirm $PACKAGES

echo ""
echo "=== Setup Complete! ==="
echo "Run ./sync-dotfiles.sh next, then log out and back in."
