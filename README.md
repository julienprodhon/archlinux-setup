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

## Pacman Configuration

`post-install.sh` applies EndeavourOS-style pacman defaults:

- `Color` - colored output
- `ILoveCandy` - Pac-Man progress bar animation
- `VerbosePkgLists` - detailed package info during transactions
- `ParallelDownloads = 5` - already enabled by default in Arch

A pacman hook (`/etc/pacman.d/hooks/clean-cache.hook`) automatically keeps only the last 2 versions of each cached package using `paccache` from `pacman-contrib`.

## Backup & Recovery

Timeshift is configured automatically by `post-install.sh` in RSYNC mode with no scheduled snapshots. `timeshift-autosnap` (AUR) handles snapshots automatically before every pacman transaction.

**Recovery if system won't boot:**
1. Boot Arch live USB
2. Mount root partition: `mount /dev/sdX1 /mnt`
3. Restore: `timeshift --restore --target-device /dev/sdX1`
4. Reinstall bootloader if needed

## Files

- `core-extra-packages.txt` - Packages installed via archinstall
- `aur-packages.txt` - AUR packages installed via yay
- `generate-config.sh` - Generates archinstall JSON config
- `post-install.sh` - Post-installation setup script
- `sync-dotfiles.sh` - Syncs dotfiles from a git repository
- `color-management.md` - DMS color system and theming setup
