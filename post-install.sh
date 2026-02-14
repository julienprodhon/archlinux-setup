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

# Configure pacman (EndeavourOS-style defaults)
echo "Configuring pacman..."
sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i '/^Color$/a ILoveCandy' /etc/pacman.conf

echo ""

# Configure Timeshift (RSYNC mode, keep 5 snapshots)
echo "Configuring Timeshift..."
sudo mkdir -p /etc/timeshift
sudo tee /etc/timeshift/timeshift.json > /dev/null <<'TIMESHIFT'
{
  "backup_device_uuid" : "",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "false",
  "include_btrfs_home_for_backup" : "false",
  "include_btrfs_home_for_restore" : "false",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "false",
  "schedule_daily" : "false",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "0",
  "count_weekly" : "0",
  "count_daily" : "0",
  "count_hourly" : "0",
  "count_boot" : "0",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "date_format" : "%Y-%m-%d %H:%M:%S",
  "exclude" : [],
  "exclude-apps" : []
}
TIMESHIFT

echo ""

# Setup pacman cache cleanup hook (keeps last 2 versions)
echo "Setting up pacman cache cleanup hook..."
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/clean-cache.hook > /dev/null <<'HOOK'
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache (keeping last 2 versions)...
When = PostTransaction
Exec = /usr/bin/paccache -rqk2
HOOK

echo ""
echo "=== Setup Complete! ==="
echo "Run ./sync-dotfiles.sh next, then log out and back in."
