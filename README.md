# archlinux-setup

Scripts for setting up Arch Linux after a fresh install.

## Usage

1. Run `archinstall` with the generated configuration:
   ```bash
   ./generate-config.sh
   ```
   This creates `archinstall_user_configuration.json` with packages from `core-extra-packages.txt`.

2. After installation, run post-install setup:
   ```bash
   ./post-install.sh
   ```
   Installs yay, Oh My Zsh (with plugins), DMS, and AUR packages.

3. Sync your dotfiles:
   ```bash
   ./sync-dotfiles.sh
   ```
   Edit `DOTFILES_REPO` in the script to point to your dotfiles repository.

## Files

- `core-extra-packages.txt` - Packages installed via archinstall
- `aur-packages.txt` - AUR packages installed via yay
- `generate-config.sh` - Generates archinstall JSON config
- `post-install.sh` - Post-installation setup script
- `sync-dotfiles.sh` - Syncs dotfiles from a git repository
