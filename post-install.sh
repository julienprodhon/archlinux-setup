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

# Install Zsh
echo "Installing Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

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
